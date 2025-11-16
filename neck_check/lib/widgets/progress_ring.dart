import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 35,
    this.thickness = 3,
    this.color,
    this.backgroundColor,
    this.strokeCap = StrokeCap.round,
    this.center,
    this.animate = true,
    this.duration = const Duration(milliseconds: 600),
    this.semanticsLabel = 'Progress',
  }) : assert(value >= 0 && value <= 1);

  /// 0.0 ~ 1.0
  final double value;
  final double size;
  final double thickness;
  final Color? color;
  final Color? backgroundColor;
  final StrokeCap strokeCap;
  final Widget? center;
  final bool animate;
  final Duration duration;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.primary;
    final bg = backgroundColor ?? cs.surfaceContainerHighest.withAlpha(189);

    Widget ring(double v) => CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(
        value: v,
        thickness: thickness,
        foreground: fg,
        background: bg,
        cap: strokeCap,
      ),
      child: center == null ? null : Center(child: center),
    );

    final painted = animate
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => ring(v),
          )
        : ring(value);

    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(size, size)),
      child: Semantics(label: semanticsLabel, value: '${(value * 100).round()}%', child: painted),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.thickness,
    required this.foreground,
    required this.background,
    required this.cap,
  });

  final double value;
  final double thickness;
  final Color foreground;
  final Color background;
  final StrokeCap cap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - thickness) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = background
      ..strokeCap = cap;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = foreground
      ..strokeCap = cap;

    // 배경 트랙
    canvas.drawCircle(center, radius, track);

    // 진행 아크 (12시 방향 시작)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final start = -math.pi / 2;
    final sweep = value.clamp(0.0, 1.0) * 2 * math.pi;
    canvas.drawArc(rect, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.value != value ||
        old.thickness != thickness ||
        old.foreground != foreground ||
        old.background != background ||
        old.cap != cap;
  }
}
