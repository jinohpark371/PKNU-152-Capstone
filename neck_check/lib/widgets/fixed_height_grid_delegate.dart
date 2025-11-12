import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class FixedHeightGridDelegate extends SliverGridDelegate {
  /// 교차축 개수를 고정하고, 주축(세로 스크롤 기준 높이)을 고정하는 GridDelegate.
  const FixedHeightGridDelegate({
    required this.crossAxisCount,
    required this.mainAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  }) : assert(crossAxisCount > 0),
       assert(mainAxisExtent >= 0);

  /// 한 행의 아이템 개수
  final int crossAxisCount;

  /// 아이템 고정 높이(세로 스크롤 기준)
  final double mainAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
    final usableCross = math.max(0.0, constraints.crossAxisExtent - totalSpacing);
    final childCross = usableCross / crossAxisCount;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: mainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCross + crossAxisSpacing,
      childMainAxisExtent: mainAxisExtent,
      childCrossAxisExtent: childCross,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(covariant FixedHeightGridDelegate oldDelegate) {
    return crossAxisCount != oldDelegate.crossAxisCount ||
        mainAxisExtent != oldDelegate.mainAxisExtent ||
        mainAxisSpacing != oldDelegate.mainAxisSpacing ||
        crossAxisSpacing != oldDelegate.crossAxisSpacing;
  }
}
