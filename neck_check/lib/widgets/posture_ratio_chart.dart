import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PostureSample {
  final DateTime measuredAt;
  final Duration badPosture;
  final Duration total;

  const PostureSample({required this.measuredAt, required this.badPosture, required this.total});

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
  @override
  Widget build(BuildContext context) {
    if (widget.samples.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('데이터가 없습니다')));
    }

    // 측정 시간 순으로 정렬
    final data = [...widget.samples]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // FlSpot.nullSpot
    final spots = List<FlSpot>.generate(data.length, (i) {
      final value = data[i].ratioPercent.clamp(0, 100).toDouble();
      if (value == 0.0) return FlSpot.nullSpot;
      return FlSpot(i.toDouble(), value);
    });

    String timeLabel(DateTime t) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    Color statusColor(double p) {
      if (p < 20) return Theme.of(context).colorScheme.primary.withAlpha(100);
      if (p < 80) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.tertiary.withRed(255);
    }

    final step = data.length <= widget.maxXTicks
        ? 1
        : (data.length / (widget.maxXTicks - 2)).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2.39,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) {
              final animatedSpots = List<FlSpot>.generate(spots.length, (i) {
                final targetY = spots[i].y;
                return FlSpot(spots[i].x, targetY * value);
              });

              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: step.toDouble(),
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          // if (i % step != 0 && i != data.length - 1) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            space: 12,
                            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
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
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((i) {
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
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
                        final i = ts.x.toInt();
                        final s = data[i];
                        return LineTooltipItem(
                          '${timeLabel(s.measuredAt)}\n${s.ratioPercent.toStringAsFixed(1)}%',
                          const TextStyle(fontWeight: FontWeight.w600),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: animatedSpots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary.withRed(255),
                          Theme.of(context).colorScheme.tertiary.withRed(255),
                        ],
                        stops: const [0.0, 0.10, 0.30, 0.70, 0.90, 1.0],
                      ),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
