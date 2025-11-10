import 'package:flutter/material.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(220, 68), // 버튼 전체 크기
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), // 내부 여백
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
        child: Text('시작'),
      ),
    );
  }
}
