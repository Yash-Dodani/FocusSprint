import 'package:flutter/material.dart';

class TodayProgressCard extends StatelessWidget {
  final double progress;

  const TodayProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF19192A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    final percent = (progress * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.grey.shade200,
                  color: const Color(0xFF5B2EFF),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's focus",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Short, powerful sprints keep you consistent.',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
