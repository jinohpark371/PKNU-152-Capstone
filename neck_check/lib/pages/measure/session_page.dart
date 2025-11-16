import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

import 'package:flutter/material.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding;

    return AdaptiveScaffold(
      body: Stack(
        children: [
          // 배경을 전체 채우기
          Positioned.fill(child: const Placeholder()),

          // 상단 중앙 상태 텍스트
          Positioned(
            top: safe.top + 24,
            left: 0,
            right: 0,
            child: Center(child: Text('측정 중...', style: Theme.of(context).textTheme.titleLarge)),
          ),

          // 하단 중앙 종료 버튼(좌우로 핀 해서 너비 확장)
          Positioned(
            left: 20,
            right: 20,
            bottom: safe.bottom + 24,
            child: ElevatedButton(
              onPressed: () => AdaptiveAlertDialog.show(
                context: context,
                title: '종료하시겠습니까?',
                actions: [
                  AlertAction(title: '취소', style: AlertActionStyle.cancel, onPressed: () {}),
                  AlertAction(
                    title: '종료',
                    style: AlertActionStyle.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(220, 68), // 버튼 전체 크기
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), // 내부 여백
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              child: const Text('측정 종료'),
            ),
          ),
        ],
      ),
    );
  }
}
