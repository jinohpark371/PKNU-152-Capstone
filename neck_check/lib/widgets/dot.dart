import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  const Dot({super.key, this.size = 10, this.color, this.isActive = true});

  final double size;
  final Color? color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Theme.of(context).colorScheme.onPrimaryContainer;
    final dotColor = isActive ? effectiveColor : effectiveColor.withAlpha(32);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
    );
  }
}
