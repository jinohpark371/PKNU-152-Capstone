import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 키보드 이벤트
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:neck_check/blocs/auth/auth_bloc.dart';
import 'package:neck_check/services/api_gateway.dart'; // ApiGateway import 필수

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  // =========================
  // 1) 서버 및 기본 설정
  // =========================
  static const String serverIp = "127.0.0.1";
  static const String serverPort = "5001";
  final ApiGateway _apiGateway = ApiGateway();

  // URL
  final String checkUrl = "http://$serverIp:$serverPort/face_data";
  final Uri startUrl = Uri.parse("http://$serverIp:$serverPort/session_start");
  final Uri stopUrl = Uri.parse("http://$serverIp:$serverPort/session_stop");
  final String snapshotUrl = "http://$serverIp:$serverPort/snapshot";

  // 상태 변수
  bool _isConnected = false; // 서버 연결 여부
  bool _isSessionActive = false; // 현재 세션(측정) 진행 중 여부

  // 타이머
  Timer? _connectionTimer; // 서버 연결 확인용 (2초 주기)
  Timer? _dataTimer; // 실시간 데이터 수신용 (33ms 주기)

  // =========================
  // 2) 측정(Session) 관련 변수 (SessionPage에서 이식)
  // =========================
  Map<String, dynamic>? _faceData;

  // 알림
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _lastAlertMessage;
  bool _notificationsInitialized = false;

  // UI/UX 제어
  final FocusNode _focusNode = FocusNode();
  bool _showBBox = true;
  bool _isResetting = false;
  OverlayEntry? _sideAlertEntry;
  Timer? _sideAlertTimer;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _checkServerConnection();

    // 주기적 서버 연결 확인
    _connectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkServerConnection();
    });
  }

  // =========================
  // 3) 초기화 및 통신 로직
  // =========================

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Linux/Windows 설정 생략 (필요 시 추가)

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(initializationSettings);
      _notificationsInitialized = true;
    } catch (e) {
      print('Notification init error: $e');
    }
  }

  Future<void> _checkServerConnection() async {
    try {
      final response = await http
          .get(Uri.parse(checkUrl))
          .timeout(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() => _isConnected = response.statusCode == 200);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnected = false);
      }
    }
  }

  // =========================
  // 4) 세션 제어 (Start / Stop / Fetch)
  // =========================

  Future<void> _toggleSession() async {
    if (_isSessionActive) {
      await _stopSession();
    } else {
      await _startSession();
    }
  }

  Future<void> _startSession() async {
    try {
      await _stopSession();
      await _apiGateway.resetCalibration();

      final res = await http.post(startUrl).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        setState(() {
          _isSessionActive = true;
          _showBBox = true; // 시작 시 박스 보이기
        });

        // 데이터 수신 타이머 시작
        _dataTimer?.cancel();
        _dataTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
          if (mounted && _isSessionActive) _fetchFaceData();
        });

        // 키보드 포커스 잡기 (단축키 위해)
        if (context.mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      } else {
        _showSnackbar('세션 시작 실패 (로그인/서버 확인)', isError: true);
      }
    } catch (e) {
      debugPrint("❌ Start Error: $e");
      _showSnackbar('서버 통신 오류', isError: true);
    }
  }

  Future<void> _stopSession() async {
    // 1. UI 상태 즉시 변경 (빠른 반응)
    setState(() {
      _isSessionActive = false;
      _faceData = null;
      _lastAlertMessage = null;
    });

    // 2. 타이머/오버레이 정리
    _dataTimer?.cancel();
    _sideAlertTimer?.cancel();
    _sideAlertEntry?.remove();
    _sideAlertEntry = null;

    // 3. 서버에 종료 요청
    try {
      final res = await http.post(stopUrl).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        _showSnackbar('세션 종료 및 로그 저장 완료');
      } else {
        _showSnackbar('세션 종료 실패 (로그 전송 오류)', isError: true);
      }
    } catch (e) {
      debugPrint("❌ Stop Error: $e");
    }
  }

  Future<void> _fetchFaceData() async {
    try {
      final data = await _apiGateway.fetchFaceData();
      if (data != null) {
        _handleAlertLogic(data);
        if (mounted) {
          setState(() => _faceData = data);
        }
      }
    } catch (e) {
      // 통신 에러 무시 (빈번할 수 있음)
    }
  }

  void _handleAlertLogic(Map<String, dynamic> data) {
    String? currentAlert = data['alert_message'];
    if (currentAlert != null && currentAlert != _lastAlertMessage) {
      _showNotification(currentAlert);
      _showSideAlert(currentAlert);
      _lastAlertMessage = currentAlert;
    } else if (currentAlert == null) {
      _lastAlertMessage = null;
    }
  }

  Future<void> _showNotification(String message) async {
    if (!_notificationsInitialized) return;
    const details = NotificationDetails(
      macOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      android: AndroidNotificationDetails('posture', 'Alerts', importance: Importance.max),
    );
    await _notificationsPlugin.show(0, '자세 교정 알림', message, details);
  }

  // =========================
  // 5) UI: Side Alert & SnackBar & Keyboard
  // =========================

  void _showSideAlert(String message) {
    _sideAlertTimer?.cancel();
    _sideAlertEntry?.remove();

    final overlay = Overlay.of(context);
    _sideAlertEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 100,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: Colors.amber,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_sideAlertEntry!);
    _sideAlertTimer = Timer(const Duration(seconds: 4), () {
      _sideAlertEntry?.remove();
      _sideAlertEntry = null;
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_isSessionActive) return; // 측정 중일 때만 단축키 동작

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        _stopSession();
      } else if (event.logicalKey == LogicalKeyboardKey.keyT) {
        setState(() => _showBBox = !_showBBox);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _resetCalibration();
      }
    }
  }

  Future<void> _resetCalibration() async {
    if (_isResetting) return;
    setState(() => _isResetting = true);
    _showSnackbar('기준 자세 재설정 중...');
    try {
      final success = await _apiGateway.resetCalibration();
      if (success) _showSnackbar("재설정 완료");
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _dataTimer?.cancel();
    _sideAlertTimer?.cancel();
    _sideAlertEntry?.remove();
    _focusNode.dispose();
    super.dispose();
  }

  // =========================
  // 6) 메인 빌드 (Main Build)
  // =========================
  @override
  Widget build(BuildContext context) {
    // 키보드 입력을 받기 위해 감쌈
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(body: _buildActiveSessionUI()),
    );
  }

  //  측정 화면 (Active Session Mode)
  Widget _buildActiveSessionUI() {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isReady = _isConnected && isAuthenticated;

    return Stack(
      children: [
        // 1. 전체 화면 영상
        Positioned.fill(
          child: Container(
            color: Colors.black, // 배경 검정
            child: CommonFrameViewer(url: snapshotUrl),
          ),
        ),

        // 2. 바운딩 박스 오버레이
        if (_showBBox)
          Positioned.fill(
            child: CustomPaint(painter: FaceBoxPainter(data: _faceData)),
          ),

        // 3. 상단 컨트롤 바
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: _isSessionActive
              ? Row(
                  crossAxisAlignment: .start,
                  children: [
                    _buildGlassBadge(
                      leading: Icon(
                        _showBBox ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                        color: Colors.white,
                        size: 14,
                      ),
                      child: Text(
                        _showBBox ? "표시 중" : "숨김",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // _buildGlassBadge(
                    //   leading: Icon(CupertinoIcons.keyboard, color: Colors.white70, size: 14),
                    //   child: Text(
                    //     "[Space] 재설정  [T] 토글  [Q] 종료",
                    //     style: TextStyle(color: Colors.white70, fontSize: 12),
                    //   ),
                    // ),
                    const Spacer(),
                    // 종료 버튼
                    _buildGlassBadge(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                        onPressed: _stopSession,
                        label: Text(
                          '종료 [Q]',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.circle, size: 8, color: Colors.red),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: .start,
                  children: [
                    _buildGlassBadge(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '자세 분석 준비',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('카메라 위치를 확인해주세요', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    _buildGlassBadge(
                      child: _ServerStatusBadge(
                        isConnected: _isConnected,
                        onPressed: isReady ? _toggleSession : null,
                      ),
                    ),
                  ],
                ),
        ),

        // 4. 하단 정보 패널
        if (_isSessionActive)
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: _buildInfoPanel(),
          ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    if (_faceData == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
          child: const Text("데이터 수신 중...", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    String interpretation = _faceData!['interpretation'] ?? "-";
    bool isCalibrated = _faceData!['is_calibrated'] ?? false;
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
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            isNormal ? "현재 자세가 좋습니다." : "자세를 바르게 고쳐주세요.",
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                isCalibrated
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.exclamationmark_triangle_fill,
                color: isCalibrated ? Colors.green : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCalibrated ? "조정됨" : "조정 필요",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBadge({Widget? leading, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [if (leading != null) leading, const SizedBox(width: 6), child]),
    );
  }
}

// =========================
// Helper Classes (통합됨)
// =========================

class _ServerStatusBadge extends StatelessWidget {
  final bool isConnected;
  final void Function()? onPressed;
  const _ServerStatusBadge({required this.isConnected, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        backgroundColor: isConnected && isAuthenticated
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
      ),
      onPressed: onPressed,
      label: Text(
        !isConnected ? '서버 연결 대기 중...' : (!isAuthenticated ? '로그인이 필요합니다' : '측정 시작하기'),
        style: TextStyle(
          color: isConnected && isAuthenticated ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Icon(
        Icons.circle,
        size: 8,
        color: isConnected && isAuthenticated ? Colors.green : Colors.red,
      ),
    );
  }
}

class CommonFrameViewer extends StatefulWidget {
  final String url;
  const CommonFrameViewer({super.key, required this.url});

  @override
  State<CommonFrameViewer> createState() => _CommonFrameViewerState();
}

class _CommonFrameViewerState extends State<CommonFrameViewer> {
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
    if (_imageBytes == null)
      return const Center(child: CircularProgressIndicator(color: Colors.white24));
    return Image.memory(
      _imageBytes!,
      gaplessPlayback: true,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class FaceBoxPainter extends CustomPainter {
  final Map<String, dynamic>? data;
  FaceBoxPainter({this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null) return;

    const double cameraW = 640.0;
    const double cameraH = 480.0;

    // 비율 계산 (화면에 꽉 차게)
    double scale = size.width / cameraW;
    double offsetX = 0;
    double offsetY = (size.height - (cameraH * scale)) / 2;

    // 만약 높이 기준으로 맞춰야 한다면 로직 조정 (여기선 width 기준 cover 가정)
    if (cameraH * scale < size.height) {
      scale = size.height / cameraH;
      offsetX = (size.width - (cameraW * scale)) / 2;
      offsetY = 0;
    }

    if (data!['is_calibrated'] == true && data!['target_bbox'] != null) {
      _drawBox(canvas, data!['target_bbox'], scale, offsetX, offsetY, Colors.white30);
    }
    if (data!['detected'] == true && data!['bbox'] != null) {
      _drawBox(canvas, data!['bbox'], scale, offsetX, offsetY, Colors.blueAccent);
    }
  }

  void _drawBox(
    Canvas canvas,
    List<dynamic> bbox,
    double scale,
    double dx,
    double dy,
    Color color,
  ) {
    double x = bbox[0] * scale + dx;
    double y = bbox[1] * scale + dy;
    double w = bbox[2] * scale;
    double h = bbox[3] * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FaceBoxPainter oldDelegate) => true;
}
