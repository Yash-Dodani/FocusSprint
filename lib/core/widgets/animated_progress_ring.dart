import 'package:flutter/material.dart';

class AnimatedProgressRing extends StatelessWidget {
  final double value;
  final double size;

  const AnimatedProgressRing({super.key, required this.value, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, v, _) {
        final percentage = (v * 100).clamp(0, 100).toStringAsFixed(0);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: 0.5,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
