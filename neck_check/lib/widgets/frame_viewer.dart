// [NEW] MJPEG 패키지 대신 이미지를 빠르게 연속으로 보여주는 위젯
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FrameViewer extends StatefulWidget {
  final String url;
  const FrameViewer({super.key, required this.url});

  @override
  State<FrameViewer> createState() => _FrameViewerState();
}

class _FrameViewerState extends State<FrameViewer> {
  Uint8List? _imageBytes;
  Timer? _timer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // 0.033초마다(초당 30회) 이미지 요청
    _timer = Timer.periodic(const Duration(milliseconds: 33), (timer) => _fetchFrame());
  }

  Future<void> _fetchFrame() async {
    try {
      // 캐시를 방지하기 위해 URL 뒤에 무작위 숫자 추가 (?t=...)
      final uri = Uri.parse("${widget.url}?t=${DateTime.now().millisecondsSinceEpoch}");
      final response = await http.get(uri).timeout(const Duration(milliseconds: 100));

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text("Connecting...", style: TextStyle(color: Colors.red)),
      );
    }
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // 깜빡임 없이 부드럽게 보여주는 핵심 (gaplessPlayback)
    return Image.memory(_imageBytes!, gaplessPlayback: true, fit: BoxFit.contain);
  }
}
