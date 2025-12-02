import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PostureSample {
  final DateTime measuredAt;
  final Duration total;

  // 세부 자세 데이터 필드
  final Duration turtle; // 거북목
  final Duration sleep; // 누운 자세
  final Duration tilted; // 옆으로 누운 자세

  const PostureSample({
    required this.measuredAt,
    required this.total,
    required this.turtle,
    required this.sleep,
    required this.tilted,
  });

  // 나쁜 자세 총합 (거북목 + 누운 자세 + 옆으로 누운 자세)
  Duration get badPosture => turtle + sleep + tilted;

  // 바른 자세 계산 (전체 - 나쁜 자세)
  Duration get goodPosture => total - badPosture;

  double get ratioPercent {
    final totalSec = total.inSeconds;
    if (totalSec <= 0) return 0;
    return (badPosture.inSeconds / totalSec) * 100.0;
  }
}

class PostureRatioChart extends StatefulWidget {
  final List<PostureSample> samples;
  final int maxXTicks;

  const PostureRatioChart({super.key, required this.samples, this.maxXTicks = 6});

  @override
  State<PostureRatioChart> createState() => _PostureRatioChartState();
}

class _PostureRatioChartState extends State<PostureRatioChart> {
  double transformValue(double realValue) {
    return realValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.samples.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('데이터가 없습니다')));
    }

    // 1. 데이터 정렬
    final data = [...widget.samples]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // 2. 메인 라인용 Spot 생성 (데이터가 0이면 끊어짐)
    final spots = List<FlSpot>.generate(data.length, (i) {
      final realValue = data[i].ratioPercent.clamp(0, 100).toDouble();
      // 값이 0이면 nullSpot을 반환하여 선을 끊음
      if (realValue == 0.0) return FlSpot.nullSpot;
      return FlSpot(i.toDouble(), transformValue(realValue));
    });

    // 시간 라벨 포맷 함수
    String timeLabel(DateTime t) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    // 상태별 점 색상
    Color statusColor(double p) {
      if (p < 20) return Theme.of(context).colorScheme.primary.withAlpha(100);
      if (p < 80) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.tertiary.withRed(255);
    }

    // X축 간격 계산
    final step = data.length <= widget.maxXTicks
        ? 1
        : (data.length / (widget.maxXTicks - 2)).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2.39,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25, // 눈금 간격 조정
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == 50 || value == 100) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${value.toInt()}%',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: step.toDouble(),
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= data.length) return const SizedBox.shrink();
                      // step에 맞지 않으면 숨김 (마지막 데이터는 표시)
                      if (i % step != 0 && i != data.length - 1) return const SizedBox.shrink();

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          timeLabel(data[i].measuredAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                // 터치 시 표시되는 인디케이터 설정
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes
                      .map((i) {
                        // 배경 점선 라인(barIndex 0)은 인디케이터 표시 안 함
                        if (barData.isCurved == true) return null;

                        final s = data[i];
                        final c = statusColor(s.ratioPercent);
                        return TouchedSpotIndicatorData(
                          FlLine(color: c, strokeWidth: 1.5, dashArray: [4, 3]),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 5,
                              color: c,
                              strokeWidth: 2,
                              strokeColor: c,
                            ),
                          ),
                        );
                      })
                      .whereType<TouchedSpotIndicatorData>()
                      .toList();
                },
                // [요청하신 부분] 툴팁 설정
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((ts) {
                      // 배경 라인(점선)의 툴팁은 무시
                      if (ts.barIndex == 0) return null;

                      final i = ts.x.toInt();
                      final s = data[i];

                      return LineTooltipItem(
                        '${timeLabel(s.measuredAt)}\n\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '나쁜자세: ${s.ratioPercent.toStringAsFixed(1)}%\n',
                            style: TextStyle(
                              color: statusColor(s.ratioPercent),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                '바른자세: ${s.goodPosture.inSeconds}초\n'
                                '거북목: ${s.turtle.inSeconds}초\n'
                                '누운 자세: ${s.sleep.inSeconds}초\n'
                                '옆으로 누운 자세: ${s.tilted.inSeconds}초',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.5, // 줄간격
                            ),
                          ),
                        ],
                        textAlign: TextAlign.left,
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // ---------------------------------------------------------
                // [추가 팁] 데이터가 없는 구간을 점선으로 연결하는 배경 라인
                // ---------------------------------------------------------
                LineChartBarData(
                  // nullSpot(끊어진 구간)을 제외하고 모든 점을 연결하는 데이터 생성
                  spots: spots.where((s) => s != FlSpot.nullSpot).toList(),
                  isCurved: false,
                  color: Colors.grey.withAlpha(80), // 연한 회색
                  barWidth: 2,
                  dashArray: [5, 5], // 점선 효과 (5픽셀 선, 5픽셀 공백)
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),

                // ---------------------------------------------------------
                // 메인 데이터 라인 (데이터가 없으면 끊김)
                // ---------------------------------------------------------
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  barWidth: 4,
                  // 메인 라인은 점을 표시하지 않음 (터치 시에만 표시됨)
                  dotData: const FlDotData(show: false),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withAlpha(100),
                      Theme.of(context).colorScheme.primary.withAlpha(100),
                      Theme.of(context).colorScheme.tertiary.withAlpha(150),
                      Theme.of(context).colorScheme.tertiary.withAlpha(150),
                      Theme.of(context).colorScheme.tertiary.withRed(255),
                      Theme.of(context).colorScheme.tertiary.withRed(255),
                    ],
                    stops: const [0.0, 0.20, 0.30, 0.50, 0.75, 1.0],
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
