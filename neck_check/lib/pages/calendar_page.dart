import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/progress_ring.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  static const _weekDays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final firstDayOfNov = DateTime(2025, 11, 1);
    final daysInNov = DateTime(2025, 12, 0).day;
    final firstDayOfDec = DateTime(2025, 12, 1);
    final daysInDec = DateTime(2026, 1, 0).day;

    final theme = Theme.of(context);
    final safeArea = MediaQuery.of(context).padding;
    final topPadding = PlatformInfo.isIOS26OrHigher() ? 70.0 : 0.0;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: '달력'),
      body: Padding(
        padding: EdgeInsets.only(top: safeArea.top + topPadding, bottom: 50, right: 20, left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) => Text(_weekDays[index], style: theme.textTheme.labelLarge),
              ),
            ),
            Divider(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 28),
                children: [
                  Text(
                    '11월',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1 / 1.75,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: firstDayOfNov.weekday - 1 + daysInNov,
                    itemBuilder: (context, index) {
                      final offset = firstDayOfNov.weekday - 1;
                      if (index <= offset) {
                        return const SizedBox.shrink();
                      }
                      final day = index - offset;

                      return Column(
                        spacing: 5,
                        children: [
                          Text(
                            '$day',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ProgressRing(value: 0.5, size: 36, thickness: 5),
                          Dot(
                            size: 5,
                            color: index % 3 == 0 ? theme.colorScheme.onPrimaryContainer : null,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  Text(
                    '12월',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1 / 1.75,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: firstDayOfDec.weekday - 1 + daysInDec,
                    itemBuilder: (context, index) {
                      final offset = firstDayOfDec.weekday - 1;
                      if (index <= offset) {
                        return const SizedBox.shrink();
                      }
                      final day = index - offset;

                      return Column(
                        spacing: 5,
                        children: [
                          Text(
                            '$day',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ProgressRing(value: 0.5, size: 36, thickness: 5),
                          Dot(
                            size: 5,
                            color: index % 3 == 0 ? theme.colorScheme.onPrimaryContainer : null,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
