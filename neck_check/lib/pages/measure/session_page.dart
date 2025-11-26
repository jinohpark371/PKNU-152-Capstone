import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  // [서버 설정]
  static const String serverIp = "127.0.0.1";
  static const String serverPort = "5001";
  final String snapshotUrl = "http://$serverIp:$serverPort/current_frame";
  final String dataUrl = "http://$serverIp:$serverPort/face_data";
  final String resetUrl = "http://$serverIp:$serverPort/calibrate_reset";

  // 상태 변수
  Timer? _timer;
  Map<String, dynamic>? _faceData;

  // [NEW] 알림 관련 변수
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _lastAlertMessage; // Python의 last_processed_alert 역할

  // 키보드 제어
  final FocusNode _focusNode = FocusNode();
  bool _showBBox = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();

    _timer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (mounted) _fetchFaceData();
    });
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'posture_channel',
      'Posture Alerts',
      channelDescription: '알림을 통해 자세 교정을 유도합니다.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails macosDetails = DarwinNotificationDetails(
      presentAlert: true, // 배너 표시
      presentBadge: true, // 뱃지 표시
      presentSound: true, // 소리 재생
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      macOS: macosDetails,
    );

    await _notificationsPlugin.show(
      0, // ID (0으로 고정하여 최신 알림이 이전 알림을 덮어쓰게 함)
      '자세 교정 알림',
      message,
      platformChannelSpecifics,
    );
  }

  Future<void> _fetchFaceData() async {
    try {
      final response = await http
          .get(Uri.parse(dataUrl))
          .timeout(const Duration(milliseconds: 200));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // [NEW] 알림 로직 처리 (Python 코드 이식)
        _handleAlertLogic(data);

        setState(() {
          _faceData = data;
        });
      }
    } catch (e) {
      // 통신 에러 무시
    }
  }

  // [NEW] Python의 알림 중복 방지 로직 이식
  void _handleAlertLogic(Map<String, dynamic> data) {
    String? currentAlert = data['alert_message'];

    // 1. 알림 메시지가 있고, 직전 알림과 다를 때만 실행
    if (currentAlert != null && currentAlert != _lastAlertMessage) {
      _showNotification(currentAlert);
      print("🔔 ALERT TRIGGERED: $currentAlert");

      // 처리한 메시지 기록
      _lastAlertMessage = currentAlert;
    }
    // 2. 서버에서 알림이 사라지면(null), 클라이언트 기억 리셋
    else if (currentAlert == null) {
      _lastAlertMessage = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        _showStopDialog(context);
      } else if (event.logicalKey == LogicalKeyboardKey.keyT) {
        setState(() => _showBBox = !_showBBox);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _resetCalibration();
      }
    }
  }

  Future<void> _resetCalibration() async {
    try {
      await http.post(Uri.parse(resetUrl));
      _showSnackBar("재설정 완료");
    } catch (e) {
      _showSnackBar("연결 실패");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 300,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    final safe = MediaQuery.of(context).padding;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. 영상 레이어
            Positioned.fill(child: FrameViewer(url: snapshotUrl)),

            // 2. 오버레이 (바운딩 박스)
            if (_showBBox)
              Positioned.fill(
                child: CustomPaint(painter: _FaceBoxPainter(data: _faceData)),
              ),

            // 3. 하단 정보 패널
            Positioned(
              left: 20,
              right: 20,
              bottom: safe.bottom + 20,
              child: _buildInfoOverlay(context),
            ),

            // 4. 상단 컨트롤 바 & 단축키 안내
            Positioned(
              top: safe.top + 10,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // 오버레이 상태 표시
                  _buildGlassBadge(
                    icon: _showBBox ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                    text: _showBBox ? "표시 중" : "숨김",
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),

                  // 단축키 안내
                  _buildGlassBadge(
                    icon: CupertinoIcons.keyboard,
                    text: "[Space] 재설정  [T] 토글  [Q] 종료",
                    color: Colors.white70,
                  ),

                  const Spacer(),

                  // 종료 버튼
                  IconButton(
                    onPressed: () => _showStopDialog(context),
                    icon: const Icon(CupertinoIcons.xmark_circle_fill),
                    color: Colors.white.withOpacity(0.8),
                    iconSize: 32,
                    tooltip: "종료",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 바 배지 스타일 (유리창 효과)
  Widget _buildGlassBadge({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 하단 정보 패널
  Widget _buildInfoOverlay(BuildContext context) {
    if (_faceData == null) {
      return Center(
        child: Text(
          "연결 대기 중...",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
        ),
      );
    }

    // 데이터 파싱
    String interpretation = _faceData!['interpretation'] ?? "-";
    bool isCalibrated = _faceData!['is_calibrated'] ?? false;
    bool isCalibrating = _faceData!['is_calibrating'] ?? false;

    // 상태 결정
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isCalibrating) {
      statusText = "조정 중...";
      statusIcon = CupertinoIcons.hourglass;
      statusColor = Colors.amber;
    } else if (isCalibrated) {
      statusText = "조정됨";
      statusIcon = CupertinoIcons.checkmark_seal_fill;
      statusColor = Colors.green;
    } else {
      statusText = "조정 필요";
      statusIcon = CupertinoIcons.exclamationmark_triangle_fill;
      statusColor = Colors.redAccent;
    }

    bool isNormal = interpretation.contains("정상");

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            interpretation,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isNormal ? "현재 자세가 좋습니다." : "자세를 바르게 고쳐주세요.",
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem(statusIcon, statusText, statusColor),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildStatusItem(CupertinoIcons.camera_fill, "실시간 분석", Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showStopDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('종료하시겠습니까?'),
        content: const Text('현재 측정이 종료됩니다.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            isDestructiveAction: true,
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}

// === FrameViewer (영상 갱신) ===
class FrameViewer extends StatefulWidget {
  final String url;
  const FrameViewer({super.key, required this.url});

  @override
  State<FrameViewer> createState() => _FrameViewerState();
}

class _FrameViewerState extends State<FrameViewer> {
  Uint8List? _imageBytes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) => _fetchFrame());
  }

  Future<void> _fetchFrame() async {
    try {
      final uri = Uri.parse("${widget.url}?t=${DateTime.now().millisecondsSinceEpoch}");
      final response = await http.get(uri).timeout(const Duration(milliseconds: 100));
      if (response.statusCode == 200 && mounted) {
        setState(() => _imageBytes = response.bodyBytes);
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) return const Center(child: CircularProgressIndicator());
    return Image.memory(_imageBytes!, gaplessPlayback: true, fit: BoxFit.cover);
  }
}

// === FaceBoxPainter (박스 그리기) ===
class _FaceBoxPainter extends CustomPainter {
  final Map<String, dynamic>? data;
  _FaceBoxPainter({this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null) return;

    const double cameraW = 640.0;
    const double cameraH = 480.0;

    double scale = size.height / cameraH;
    double offsetX = (size.width - (cameraW * scale)) / 2;
    double offsetY = (size.height - (cameraH * scale)) / 2;

    if (size.width > cameraW * scale) {
      scale = size.width / cameraW;
      offsetX = 0;
      offsetY = (size.height - (cameraH * scale)) / 2;
    }

    if (data!['is_calibrated'] == true && data!['target_bbox'] != null) {
      _drawBox(
        canvas,
        data!['target_bbox'],
        scale,
        offsetX,
        offsetY,
        Colors.white.withOpacity(0.3),
        "기준",
      );
    }

    if (data!['detected'] == true && data!['bbox'] != null) {
      _drawBox(canvas, data!['bbox'], scale, offsetX, offsetY, Colors.blueAccent, "현재");
    }
  }

  void _drawBox(
    Canvas canvas,
    List<dynamic> bbox,
    double scale,
    double dx,
    double dy,
    Color color,
    String label,
  ) {
    double x = bbox[0] * scale + dx;
    double y = bbox[1] * scale + dy;
    double w = bbox[2] * scale;
    double h = bbox[3] * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(12));
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceBoxPainter oldDelegate) => true;
}
