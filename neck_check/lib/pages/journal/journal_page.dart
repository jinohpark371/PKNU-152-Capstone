import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/stats/stats_bloc.dart';
import 'package:neck_check/util.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/posture_ratio_chart.dart';
import 'package:neck_check/widgets/progress_ring.dart';

import 'calendar_page.dart';

String _formatDuration(int totalSeconds) {
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;

  final String h = hours.toString().padLeft(1, '0');
  final String m = minutes.toString().padLeft(1, '0');
  final String s = seconds.toString().padLeft(1, '0');

  if (hours > 0) {
    return '${h}h ${m}m ${s}s';
  } else if (minutes > 0) {
    return '${m}m ${s}s';
  } else {
    return '${s}s';
  }
}

String formatDate(DateTime date) {
  final String year = date.year.toString();
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(FetchStatsDetail(formatDate(date.value)));
  }

  @override
  void dispose() {
    date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      addAutomaticKeepAlives: true,
      padding: const EdgeInsets.all(60),
      children: [
        _Header(date),
        const Divider(height: 20),
        _RingTabBar(date),
        const Divider(height: 20),
        _SummaryDisplay(date),
        const Divider(height: 20),
        _GraphDisplay(),
        const Divider(height: 20),
        StatsGridView(),

        const SizedBox(height: 5),
        const Divider(height: 20),
        const SizedBox(height: 10),
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
                    child: Column(
                      children: [
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            context.read<StatsBloc>().add(
                              FetchStatsDetail(formatDate(currentDate)),
                            );
                            date.value = currentDate;
                          },
                          child: ProgressRing(
                            value: 1,
                            center: Text(weekday(index), style: theme.textTheme.labelLarge),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            }),
            SizedBox(height: 8),
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
          return BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              // 1. 초기화 (초 단위)
              int totalGoodSec = 0;
              int totalTurtleSec = 0;
              int totalSleepSec = 0;
              int totalTiltedSec = 0;

              // 2. 데이터 집계
              if (state is StatsDetailLoaded && state.timeline.isNotEmpty) {
                for (var item in state.timeline) {
                  // item.value가 Map인지 확인 (서버 응답 구조: {"Good": 45, "Turtle": 15})
                  if (item.value is Map) {
                    final map = item.value as Map;

                    // 값이 int나 double일 수 있으므로 num으로 받아 toInt() 처리
                    totalGoodSec += (map['Good'] as num? ?? 0).toInt();
                    totalTurtleSec += (map['Turtle'] as num? ?? 0).toInt();
                    totalSleepSec += (map['Sleep'] as num? ?? 0).toInt();
                    totalTiltedSec += (map['Tilted'] as num? ?? 0).toInt();
                  }
                }
              }
              final totalWorkSec = totalGoodSec + totalTurtleSec + totalSleepSec + totalTiltedSec;

              final ratio = totalWorkSec == 0 ? 0.0 : totalGoodSec / totalWorkSec;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressRing(
                    value: ratio,
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
                              (ratio * 100).round().toString(),
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
                      // [FIX] workTimeDuration getter 사용
                      Text(
                        _formatDuration(totalWorkSec),
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
                      // [FIX] goodPoseDuration getter 사용
                      Text(
                        _formatDuration(totalGoodSec),
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
                  IconButton.filledTonal(
                    onPressed: () {
                      context.read<StatsBloc>().add(FetchStatsDetail(formatDate(date.value)));
                    },
                    icon: Icon(CupertinoIcons.refresh),
                  ),
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('측정 시간')]),
        SizedBox(height: 26),
        BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            List<PostureSample> sample = [];
            if (state is StatsDetailLoaded) {
              // 차트의 X축 정렬을 위해 임의의 날짜(오늘)에 시간(HH:MM)을 결합합니다.
              final now = DateTime.now();

              sample = state.timeline.map((item) {
                // 1. "HH:MM" 문자열을 파싱하여 DateTime 생성
                final parts = item.time.split(':');
                final hour = int.tryParse(parts[0]) ?? 0;
                final minute = int.tryParse(parts[1]) ?? 0;
                final measuredAt = DateTime(now.year, now.month, now.day, hour, minute);

                // 2. 값 추출 및 계산
                int totalSeconds = 0;
                int turtle = 0;
                int sleep = 0;
                int tilted = 0;

                // item.value가 Map인지 확인
                if (item.value is Map) {
                  final map = item.value as Map;

                  // (1) 나쁜 자세 시간 (예: 'Turtle')
                  // 키 값은 서버 로직에 따라 다를 수 있으니 'Turtle' 등을 확인하세요.
                  // 숫자가 int가 아닐 수도 있으므로 num으로 받아 형변환합니다.
                  turtle = (map['Turtle'] as num? ?? 0).toInt();
                  sleep += (map['Sleep'] as num? ?? 0).toInt();
                  tilted += (map['Tilted'] as num? ?? 0).toInt();

                  // (2) 총 시간 (모든 value의 합)
                  for (var v in map.values) {
                    totalSeconds += (v as num? ?? 0).toInt();
                  }
                }
                return PostureSample(
                  measuredAt: measuredAt,
                  total: Duration(seconds: totalSeconds),
                  turtle: Duration(seconds: turtle),
                  sleep: Duration(seconds: sleep),
                  tilted: Duration(seconds: tilted),
                );
              }).toList();
            }

            return PostureRatioChart(samples: sample);
          },
        ),
        SizedBox(height: 26),
      ],
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

class StatsGridView extends StatelessWidget {
  const StatsGridView({super.key});

  // 시간을 예쁘게 포맷팅하는 헬퍼 함수

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        // 1. 초기화 (초 단위)
        int totalGoodSec = 0;
        int totalTurtleSec = 0;
        int totalSleepSec = 0;
        int totalTiltedSec = 0;

        String startTime = '--:--'; // 데이터 없을 때 표시할 기본값
        String endTime = '--:--'; // 데이터 없을 때 표시할 기본값

        // 2. 데이터 집계
        if (state is StatsDetailLoaded && state.timeline.isNotEmpty) {
          startTime = state.timeline.first.time;
          endTime = state.timeline.last.time;
          for (var item in state.timeline) {
            // item.value가 Map인지 확인 (서버 응답 구조: {"Good": 45, "Turtle": 15})
            if (item.value is Map) {
              final map = item.value as Map;

              // 값이 int나 double일 수 있으므로 num으로 받아 toInt() 처리
              totalGoodSec += (map['Good'] as num? ?? 0).toInt();
              totalTurtleSec += (map['Turtle'] as num? ?? 0).toInt();
              totalSleepSec += (map['Sleep'] as num? ?? 0).toInt();
              totalTiltedSec += (map['Tilted'] as num? ?? 0).toInt();
            }
          }
        }

        // 3. UI 렌더링
        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: IconCard(
                            icon: CupertinoIcons.alarm_fill,
                            title: startTime, // 계산된 시작 시간 적용
                            buttonText: '시작 시간',
                          ),
                        ),
                        Expanded(
                          child: IconCard(
                            icon: CupertinoIcons.moon_fill,
                            title: endTime,
                            buttonText: '종료 시간',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 하단 그리드 (자세별 통계)
            GridView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 100, // 카드 높이
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              children: [
                IconCard(
                  icon: CupertinoIcons.person_crop_circle_fill,
                  title: _formatDuration(totalGoodSec),
                  buttonText: '바른 자세 시간',
                ),
                IconCard(
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  title: _formatDuration(totalTurtleSec),
                  buttonText: '거북목 자세 시간',
                ),
                IconCard(
                  icon: CupertinoIcons.bed_double_fill,
                  title: _formatDuration(totalSleepSec),
                  buttonText: '누운 자세 시간',
                ),
                IconCard(
                  icon: CupertinoIcons.arrow_left_right,
                  title: _formatDuration(totalTiltedSec),
                  buttonText: '옆으로 기댄 자세 시간',
                ),
              ],
            ),
          ],
        );
      },
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
