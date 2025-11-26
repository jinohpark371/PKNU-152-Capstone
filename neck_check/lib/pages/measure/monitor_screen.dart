import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 키보드 입력을 위해 필요
import 'package:http/http.dart' as http;
import 'package:neck_check/widgets/frame_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posture Corrector Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MonitorScreen(),
    );
  }
}

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  // 데스크톱은 로컬 서버(같은 PC)일 확률이 높으므로 localhost 사용
  // 만약 다른 PC라면 해당 PC의 IP를 입력하세요.
  static const String serverIp = "127.0.0.1";
  static const String serverPort = "5001";

  final String snapshotUrl = "http://$serverIp:$serverPort/current_frame";
  final String dataUrl = "http://$serverIp:$serverPort/face_data";
  final String resetUrl = "http://$serverIp:$serverPort/calibrate_reset";

  Map<String, dynamic>? _faceData;
  Timer? _dataFetcher;
  bool _isRunning = true;

  // 상태 변수 (파이썬 클라이언트와 동일 기능)
  bool _showBBox = true; // [T] 키로 토글
  String? _lastAlert;

  // 키보드 입력을 받기 위한 포커스 노드
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startDataFetching();
  }

  @override
  void dispose() {
    _isRunning = false;
    _dataFetcher?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // 1. 주기적 데이터 수신 (0.03초 = 약 30fps)
  void _startDataFetching() {
    _dataFetcher = Timer.periodic(const Duration(milliseconds: 30), (timer) async {
      if (!_isRunning) return;
      try {
        final response = await http
            .get(Uri.parse(dataUrl))
            .timeout(const Duration(milliseconds: 500));
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _faceData = json.decode(response.body);
            });
            _handleAlerts();
          }
        }
      } catch (e) {
        // 서버가 꺼져있거나 연결 실패 시 조용히 넘어감 (재시도)
      }
    });
  }

  // 2. 알림 처리 (중복 방지 로직 포함)
  void _handleAlerts() {
    if (_faceData == null) return;
    String? currentAlert = _faceData!['alert_message'];

    // 알림이 있고, 이전 알림과 다를 때만 스낵바 표시
    if (currentAlert != null && currentAlert != _lastAlert) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 이전 알림 즉시 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🔔 $currentAlert",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, // 데스크톱에선 띄우는 게 보기 좋음
          width: 400, // 너무 넓지 않게 제한
          duration: const Duration(seconds: 3),
        ),
      );
      _lastAlert = currentAlert;
    } else if (currentAlert == null) {
      _lastAlert = null; // 알림 상태 리셋
    }
  }

  // 3. 캘리브레이션 초기화 요청 (Spacebar)
  Future<void> _resetCalibration() async {
    try {
      await http.post(Uri.parse(resetUrl));
      _showToast("✅ Calibration Reset Initiated");
    } catch (e) {
      _showToast("❌ Reset Failed: Server not reachable");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        width: 300,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 4. 키보드 입력 처리
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        // [Q] 앱 종료
        exit(0);
      } else if (event.logicalKey == LogicalKeyboardKey.keyT) {
        // [T] 바운딩 박스 토글
        setState(() {
          _showBBox = !_showBBox;
        });
        _showToast("Overlay: ${_showBBox ? 'ON' : 'OFF'}");
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        // [Space] 캘리브레이션 리셋
        _resetCalibration();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱이 시작되면 키보드 포커스를 요청
    FocusScope.of(context).requestFocus(_focusNode);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Posture Corrector (Desktop Client)"),
          backgroundColor: Colors.grey[900],
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  "[Q] Quit  [T] Toggle Box  [Space] Reset",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            // [좌측] 메인 비디오 영역
            Expanded(
              flex: 3,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 4 / 3, // 일반적인 웹캠 비율
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Layer 1: 비디오 스트림
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[800]!)),
                        child: FrameViewer(url: snapshotUrl),
                      ),
                      // Layer 2: 오버레이 (바운딩 박스)
                      if (_showBBox) CustomPaint(painter: BoundingBoxPainter(data: _faceData)),
                    ],
                  ),
                ),
              ),
            ),

            // [우측] 정보 패널 (데스크톱 UI 레이아웃)
            Container(
              width: 300,
              color: Colors.grey[900],
              padding: const EdgeInsets.all(20),
              child: _buildSidePanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    if (_faceData == null) {
      return const Center(
        child: Text("Waiting for Data...", style: TextStyle(color: Colors.grey)),
      );
    }

    bool isCalibrated = _faceData!['is_calibrated'] ?? false;
    bool isCalibrating = _faceData!['is_calibrating'] ?? false;
    String interpretation = _faceData!['interpretation'] ?? "N/A";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "STATUS MONITOR",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),

        // 1. 자세 상태
        Text("Posture Status", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          interpretation,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: interpretation.contains("정상") ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ),
        const SizedBox(height: 40),

        // 2. 캘리브레이션 상태
        Text("Calibration", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 10),
        _buildStatusIndicator("Active", isCalibrated, Colors.green),
        const SizedBox(height: 10),
        _buildStatusIndicator("Processing", isCalibrating, Colors.yellow),

        const Spacer(),

        // 하단 안내
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
          child: const Text(
            "Tip: Sit straight and press [Space] to reset calibration.",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey[800],
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] : [],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// 캔버스 위에 박스를 그리는 페인터 (좌표 변환 로직 포함)
class BoundingBoxPainter extends CustomPainter {
  final Map<String, dynamic>? data;

  BoundingBoxPainter({this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null) return;

    // 파이썬 OpenCV 기본 해상도 가정 (변경 필요 시 여기서 수정)
    const double cameraWidth = 640.0;
    const double cameraHeight = 480.0;

    // 화면 크기에 맞게 좌표 비율 계산
    final double scaleX = size.width / cameraWidth;
    final double scaleY = size.height / cameraHeight;

    // 1. Reference Box (빨간색 - 기준값)
    if (data!['target_bbox'] != null) {
      var box = data!['target_bbox'];
      _drawRect(canvas, box, scaleX, scaleY, Colors.red.withOpacity(0.5), "Ref");
    }

    // 2. Detected Box (파란색 - 현재값)
    if (data!['bbox'] != null && data!['detected'] == true) {
      var box = data!['bbox'];
      _drawRect(canvas, box, scaleX, scaleY, Colors.blueAccent, "Target");
    }
  }

  void _drawRect(
    Canvas canvas,
    List<dynamic> box,
    double sx,
    double sy,
    Color color,
    String label,
  ) {
    double x = box[0] * sx;
    double y = box[1] * sy;
    double w = box[2] * sx;
    double h = box[3] * sy;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);

    // 박스 위 텍스트 (옵션)
    /*
    final textSpan = TextSpan(text: label, style: TextStyle(color: color, fontSize: 12));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y - 15));
    */
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
