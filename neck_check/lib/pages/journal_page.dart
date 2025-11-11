import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neck_check/mock_data.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/fixed_height_grid_delegate.dart';
import 'package:neck_check/widgets/posture_ratio_chart.dart';
import 'package:neck_check/widgets/progress_ring.dart';

import 'calendar_page.dart';

/// 위젯은 Material3 Component
/// 텍스트는 Material3 TextTheme
/// 아이콘은 CupertinoIcons

//             PostureSample(
//               measuredAt: DateTime(2025, 11, 1, 9, 0),
//               badPosture: Duration(minutes: 3),
//               total: Duration(minutes: 28),
//             ),
/// 1. 1분단위 그래프 데이터
///   1. 정상, 거북목, 누운자세, 옆으로 기댄 자세, 자리비움 라벨링
///   2. (bad point)/(good+bad point) % 비율
/// 2. 총 측정시간, 총 바른자세 시간, 총 집중한 시간, 총 안좋은 자세 시간
/// 3. 세션 시작/종료 시간
///
/// 할일
/// 2. 필요한 데이터 구조 JSON으로 구상
///
/// 1. 로그인 기능
/// 2. 상태관리

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.only(
        top: safeArea.top + 35,
        bottom: safeArea.bottom + kBottomNavigationBarHeight,
      ),
      children: [
        _Header(),
        const Divider(height: 20),
        _RingTabBar(),
        const Divider(height: 20),
        _SummaryDisplay(),
        const Divider(height: 20),
        _GraphDisplay(),
        const Divider(height: 20),
        Card(
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
        ),
        const SizedBox(height: 10),
        GridView(
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
        ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('토요일', style: theme.textTheme.displayMedium),
        SizedBox(width: 5),
        Text('11월1일', style: theme.textTheme.bodyMedium),
        Spacer(),
        IconButton.filledTonal(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => CalendarPage()));
          },
          icon: Icon(CupertinoIcons.calendar),
        ),
      ],
    );
  }
}

class _RingTabBar extends StatelessWidget {
  const _RingTabBar();

  static const _weekDays = ['일', '월', '화', '수', '목', '금', '토'];
  static const _mockData = [0.82, 0.74, 0.91, 0.65, 0.88, 0.53, 0.59];

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
              final dotColor = index == 0
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onPrimaryContainer.withAlpha(75);
              return Column(
                children: [
                  SizedBox(height: 6),
                  ProgressRing(
                    value: _mockData[index],
                    center: Text(_weekDays[index], style: theme.textTheme.labelLarge),
                  ),
                  SizedBox(height: 8),
                  Dot(size: 5, color: dotColor),
                ],
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
  const _SummaryDisplay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressRing(
            value: 0.59,
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
                    Text('59', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
              Text('5시간 34분', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Text('4시간 57분', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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

class _InfoDisplay extends StatelessWidget {
  const _InfoDisplay();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16))),
      ],
    );
  }
}
