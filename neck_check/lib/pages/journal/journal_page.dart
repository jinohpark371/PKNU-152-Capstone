import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/journal/journal_bloc.dart';
import 'package:neck_check/models/journal_data.dart';
import 'package:neck_check/models/mock_data.dart';
import 'package:neck_check/util.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/fixed_height_grid_delegate.dart';
import 'package:neck_check/widgets/posture_ratio_chart.dart';
import 'package:neck_check/widgets/progress_ring.dart';

import 'calendar_page.dart';

/// 위젯은 Material3 Component
/// 텍스트는 Material3 TextTheme
/// 아이콘은 CupertinoIcons

/// 서버 필요없는 데이터: 요일, 날짜
/// 서버 필요한 데이터: goodPoseRatio, isGoal

/// 1. ValueNotifier 다시 롤백 <완료>
/// 2. 탭바 만들기 (GoRouter 참고)
/// 3. CustomScrollView, SliverPersistentHeader(pinned: true)

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());

  @override
  void dispose() {
    date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.only(
        top: safeArea.top + 35,
        bottom: safeArea.bottom + kBottomNavigationBarHeight,
      ),
      children: [
        _Header(date),
        const Divider(height: 20),
        _RingTabBar(date),
        const Divider(height: 20),
        _SummaryDisplay(date),
        const Divider(height: 20),
        _GraphDisplay(),
        const Divider(height: 20),
        _GoalCard(),
        const SizedBox(height: 10),
        _StatsGidView(),
        const SizedBox(height: 5),
        const Divider(height: 20),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: () {}, child: Text('업무 노트 추가')),
        ),
        const SizedBox(height: 5),
        const Divider(height: 20),

        Row(
          children: [
            Text('온라인 백업: '),
            Dot(color: Colors.green),
            Text('동기화 완료'),
          ],
        ),
        const SizedBox(height: 35),
        Align(
          alignment: AlignmentGeometry.centerLeft,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('이 날짜 삭제', style: TextStyle(decoration: TextDecoration.underline)),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.date);

  final ValueNotifier<DateTime> date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: date,
      builder: (context, value, child) {
        final weekdayLabel = weekdayByDate(value);
        final dateLabel = '${value.month}월${value.day}일';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$weekdayLabel요일', style: theme.textTheme.displayMedium),
            SizedBox(width: 5),
            Text(dateLabel, style: theme.textTheme.bodyMedium),
            Spacer(),
            IconButton.filledTonal(
              onPressed: () async {
                await Navigator.of(context)
                    .push<DateTime>(
                      MaterialPageRoute(fullscreenDialog: true, builder: (_) => CalendarPage()),
                    )
                    .then((value) {
                      if (value != null) {
                        date.value = value;
                      }
                    });
              },
              icon: Icon(CupertinoIcons.calendar),
            ),
          ],
        );
      },
    );
  }
}

class _RingTabBar extends StatelessWidget {
  const _RingTabBar(this.date);
  final ValueNotifier<DateTime> date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(7, (index) {
              final theme = Theme.of(context);

              return ValueListenableBuilder(
                valueListenable: date,
                builder: (context, value, child) {
                  final currentWeekday = value.weekday % 7;
                  final offset = index - currentWeekday;

                  final currentDate = value.add(Duration(days: offset));
                  return Opacity(
                    opacity: currentWeekday == index ? 1.0 : 0.38,
                    child: BlocBuilder<JournalBloc, JournalState>(
                      builder: (context, state) {
                        JournalData data = JournalData.empty(start: currentDate);
                        if (state is JournalSuccess) data = state.dataByDate(currentDate);
                        final isZero = data.goodRatio == 0.0;

                        return Column(
                          children: [
                            SizedBox(height: 6),
                            GestureDetector(
                              onTap: !isZero ? () => date.value = currentDate : null,
                              child: ProgressRing(
                                value: data.goodRatio,
                                center: Text(weekday(index), style: theme.textTheme.labelLarge),
                              ),
                            ),
                            SizedBox(height: 8),
                            if (!isZero) Dot(size: 5, isActive: data.isGoal),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            }),
            IconButton.filledTonal(onPressed: () {}, icon: Icon(CupertinoIcons.folder_badge_plus)),
          ],
        ),
      ],
    );
  }
}

class _SummaryDisplay extends StatelessWidget {
  const _SummaryDisplay(this.date);
  final ValueNotifier<DateTime> date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ValueListenableBuilder(
        valueListenable: date,
        builder: (context, currentDate, child) {
          return BlocBuilder<JournalBloc, JournalState>(
            builder: (context, state) {
              JournalData data = JournalData.empty(start: currentDate);
              if (state is JournalSuccess) data = state.dataByDate(currentDate);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressRing(
                    value: data.goodRatio,
                    size: 118,
                    thickness: 12,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              (data.goodRatio * 100).round().toString(),
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            Text('%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          iconAlignment: IconAlignment.end,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          label: Text('분석'),
                          icon: Icon(CupertinoIcons.right_chevron),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDuration(data.workTime),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        iconAlignment: IconAlignment.end,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        label: Text('업무한 시간'),
                        icon: Icon(CupertinoIcons.right_chevron),
                      ),
                      SizedBox(height: 5),
                      Text(
                        formatDuration(data.goodPose),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        iconAlignment: IconAlignment.end,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        label: Text('바른 자세를 유지한 시간'),
                        icon: Icon(CupertinoIcons.right_chevron),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(onPressed: () {}, icon: Icon(CupertinoIcons.share)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _GraphDisplay extends StatefulWidget {
  const _GraphDisplay();

  @override
  State<_GraphDisplay> createState() => _GraphDisplayState();
}

class _GraphDisplayState extends State<_GraphDisplay> {
  int? _value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _createChoiceChip(0, '측정 시간', CupertinoIcons.stopwatch_fill),
            _createChoiceChip(1, '거북목', CupertinoIcons.person_alt),
            _createChoiceChip(2, '누운 자세', CupertinoIcons.bed_double_fill),
            _createChoiceChip(3, '옆으로 기댄 자세', CupertinoIcons.arrow_left_right),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('측정 시간'),
            TextButton.icon(
              onPressed: null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(CupertinoIcons.camera),
              label: Text('카메라'),
            ),
          ],
        ),
        SizedBox(height: 26),
        PostureRatioChart(samples: mockGraphData),
        SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const FixedHeightGridDelegate(
                    crossAxisCount: 2,
                    mainAxisExtent: 25,
                    // mainAxisSpacing: 10,
                  ),
                  children: [
                    rowWidgets(Theme.of(context).colorScheme.primary, '집중시간', '2시간 40분'),
                    rowWidgets(Theme.of(context).colorScheme.secondary, '자리비움', '0시간 24분'),
                    rowWidgets(Theme.of(context).colorScheme.tertiary, '안좋은 자세', '1시간 40분'),
                  ],
                ),

                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('더 보기', style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _createChoiceChip(int id, String title, IconData icon) {
    final selected = _value == id;
    return ChoiceChip(
      padding: selected ? const EdgeInsets.symmetric(vertical: 4, horizontal: 4) : EdgeInsets.zero,
      shape: const StadiumBorder(),
      label: selected ? Text(title) : Icon(icon, size: 20),
      selected: selected,
      onSelected: (_) => setState(() => _value = id),
      avatar: selected ? Icon(icon) : null,
      showCheckmark: false,
    );
  }

  Widget rowWidgets(Color color, String title, String time) => Row(
    children: [
      Dot(color: color),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 5),
      Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ],
  );
}

class _StatsGidView extends StatelessWidget {
  const _StatsGidView();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const FixedHeightGridDelegate(
        crossAxisCount: 2,
        mainAxisExtent: 60, // 아이템 고정 높이
        mainAxisSpacing: 10,
      ),
      children: [
        IconCard(icon: CupertinoIcons.checkmark_seal_fill, title: '88%', buttonText: '업무 성취'),
        IconCard(
          icon: CupertinoIcons.person_crop_circle_fill,
          title: '30 min',
          buttonText: '평균 바른자세',
        ),
        IconCard(
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          title: '10 min',
          buttonText: '평균 거북목',
        ),
        IconCard(icon: CupertinoIcons.bolt_fill, title: '45 min', buttonText: '집중력'),
        IconCard(icon: CupertinoIcons.bell_fill, title: '94', buttonText: '경고횟수'),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.flag_fill, size: 20),
                SizedBox(width: 15),
                Text('작업 목표: 놓침'),
                SizedBox(),
                IconButton(
                  onPressed: null,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(CupertinoIcons.question_circle_fill),
                  iconSize: 20,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: IconCard(
                    icon: CupertinoIcons.alarm_fill,
                    title: '09:24',
                    buttonText: '시작 시간',
                  ),
                ),
                Expanded(
                  child: IconCard(
                    icon: CupertinoIcons.moon_fill,
                    title: '18:58',
                    buttonText: '종료 시간',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IconCard extends StatelessWidget {
  const IconCard({super.key, this.icon, required this.title, required this.buttonText});

  final IconData? icon;
  final String title;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: () {},
          iconAlignment: IconAlignment.end,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          label: Text(buttonText),
          icon: Icon(CupertinoIcons.right_chevron),
        ),
      ],
    );
    if (icon != null) {
      child = Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        spacing: 10,
        children: [Icon(icon), child],
      );
    }

    return child;
  }
}
