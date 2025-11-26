import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/journal/journal_bloc.dart';
import 'package:neck_check/models/journal_data.dart';
import 'package:neck_check/util.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/fixed_height_grid_delegate.dart';
import 'package:neck_check/widgets/progress_ring.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('달력')),
      body: Material(
        child: Padding(
          padding: EdgeInsets.only(top: 25, right: 20, left: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  7,
                  (index) => Text(weekday(index), style: theme.textTheme.labelLarge),
                ),
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
        itemCount: firstDay.weekday + days,
        itemBuilder: (context, index) {
          final offset = firstDay.weekday - 1;
          if (index <= offset) {
            return const SizedBox.shrink();
          }
          final day = index - offset;

          final currentDate = DateTime(year, month, day);

          return BlocBuilder<JournalBloc, JournalState>(
            builder: (context, state) {
              JournalData data = JournalData.empty(start: currentDate);
              if (state is JournalSuccess) data = state.dataByDate(currentDate);

              final isZero = data.goodRatio == 0;

              return GestureDetector(
                onTap: !isZero ? () => Navigator.of(context).pop<DateTime>(currentDate) : null,
                child: Column(
                  children: [
                    Text('$day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ProgressRing(value: data.goodRatio, size: 39, thickness: 5),
                    const SizedBox(height: 4),
                    if (!isZero) Dot(size: 4, isActive: data.isGoal),
                  ],
                ),
              );
            },
          );
        },
      ),
    ];
  }
}
