import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/fixed_height_grid_delegate.dart';
import 'package:neck_check/widgets/progress_ring.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeArea = MediaQuery.of(context).padding;
    final topPadding = PlatformInfo.isIOS26OrHigher() ? safeArea.top + 62.0 : 25.0;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: '달력'),
      body: Material(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding, right: 20, left: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  const weekDays = ['일', '월', '화', '수', '목', '금', '토'];
                  return Text(weekDays[index], style: theme.textTheme.labelLarge);
                }),
              ),
              SizedBox(height: 4),
              Divider(height: 0),
              // 달력 부분
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 32),
                  children: [
                    ...buildCalendar(2025, 11),
                    SizedBox(height: 27),

                    ...buildCalendar(2025, 12),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildCalendar(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final days = DateTime(year, month + 1, 0).day;

    return [
      Text('${firstDay.month}월', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const FixedHeightGridDelegate(
          crossAxisCount: 7,
          mainAxisExtent: 81, // 아이템 고정 높이
          mainAxisSpacing: 14,
        ),
        itemCount: firstDay.weekday - 1 + days,
        itemBuilder: (context, index) {
          final offset = firstDay.weekday - 1;
          if (index <= offset) {
            return const SizedBox.shrink();
          }
          final day = index - offset;

          return Column(
            children: [
              Text('$day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ProgressRing(value: 0.5, size: 39, thickness: 5),
              const SizedBox(height: 4),
              Dot(
                size: 4,
                color: index % 3 == 0 ? Theme.of(context).colorScheme.onPrimaryContainer : null,
              ),
            ],
          );
        },
      ),
    ];
  }
}
