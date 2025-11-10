import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neck_check/sample_data.dart';
import 'package:neck_check/widgets/dot.dart';
import 'package:neck_check/widgets/posture_ratio_chart.dart';
import 'package:neck_check/widgets/progress_ring.dart';

/// 위젯은 Material3 Component
/// 텍스트는 Material3 TextTheme
/// 아이콘은 CupertinoIcons

//             PostureSample(
//               measuredAt: DateTime(2025, 11, 1, 9, 0),
//               badPosture: Duration(minutes: 3),
//               total: Duration(minutes: 28),
//             ),
/// 날짜, 시간 데이터: 년/월/일/시/분 (1분단위)
///

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.only(top: safeArea.top + 35, bottom: 200),
      children: [
        _Header(),
        const Divider(height: 20),
        _RingTabBar(),
        const Divider(height: 20),
        _SummaryDisplay(),
        const Divider(height: 20),
        _GraphDisplay(),
        const Divider(height: 20),
        _InfoDisplay(),
        const Divider(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: () {}, child: Text('업무 노트 추가')),
        ),
      ],
    );
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
        IconButton.filledTonal(onPressed: () {}, icon: Icon(CupertinoIcons.calendar)),
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
            _createChoiceChip(1, '집중한 시간', CupertinoIcons.eye),
            _createChoiceChip(2, '자리비움', CupertinoIcons.bed_double_fill),
            _createChoiceChip(3, '안좋은 자세', CupertinoIcons.exclamationmark_triangle_fill),
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
        PostureRatioChart(samples: graphSamples),
        SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                rowWidgets(Theme.of(context).colorScheme.primary, '집중한 시간', '2시간 40분'),
                rowWidgets(Theme.of(context).colorScheme.secondary, '자리비움', '0시간 24분'),
                rowWidgets(Theme.of(context).colorScheme.tertiary, '안좋은 자세', '1시간 40분'),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('더보기', style: TextStyle(decoration: TextDecoration.underline)),
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
      SizedBox(width: 10),
      Text(title),
      SizedBox(width: 10),
      Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
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
