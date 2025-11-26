import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 서버 체크용
import 'session_page.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  // 서버 설정 (session_page와 동일하게 맞춤)
  static const String serverIp = "127.0.0.1";
  static const String serverPort = "5001";
  final String checkUrl = "http://$serverIp:$serverPort/face_data";

  bool _isConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
    // 2초마다 주기적으로 서버 생존 여부 확인
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkServerConnection();
    });
  }

  Future<void> _checkServerConnection() async {
    try {
      final response = await http
          .get(Uri.parse(checkUrl))
          .timeout(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _isConnected = response.statusCode == 200;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Align(
                alignment: .centerLeft,
                child: Icon(
                  CupertinoIcons.camera_viewfinder,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '자세 분석',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '카메라를 통해 실시간으로\n목 자세를 분석하고 교정합니다.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600], height: 1.5),
              ),

              const Spacer(),

              // 2. 서버 상태 표시 (JournalPage의 "온라인 백업" 스타일)
              Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    '서버 상태',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  _Dot(color: _isConnected ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? '연결됨' : '연결 안 됨',
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              const SizedBox(height: 20),

              // 3. 시작 버튼
              ElevatedButton(
                onPressed: _isConnected
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => const SessionPage(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(220, 68), // 버튼 전체 크기
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), // 내부 여백
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
                child: Text(_isConnected ? '분석 시작하기' : '서버 연결 대기 중...'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// JournalPage 스타일의 Dot 위젯 (파일이 없을 경우를 대비해 내부 구현)
class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
      ),
    );
  }
}
