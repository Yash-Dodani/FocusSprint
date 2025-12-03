import 'package:flutter/material.dart';

import '../../data/models/sprint.dart';
import '../timer/timer_screen.dart';

class SprintTile extends StatelessWidget {
  final Sprint sprint;

  const SprintTile({super.key, required this.sprint});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF19192A) : Colors.white;
    final textPrimary = isDark
        ? const Color.fromARGB(255, 199, 104, 104)
        : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    final statusText = sprint.completed ? 'Completed' : 'In progress';

    return GestureDetector(
      onTap: () {
        if (sprint.completed) {
          // completed sprint – nothing to resume
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This sprint is already completed ✅')),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TimerScreen(sprint: sprint)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // left icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4F7CFF).withOpacity(isDark ? 0.4 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF4F7CFF),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sprint.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decoration: sprint.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sprint.categoryLabel} • ${sprint.durationMinutes} min • $statusText',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // right arrow – small scale animation on tap via GestureDetector above
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

extension on Sprint {
  String get categoryLabel {
    switch (category) {
      case SprintCategory.study:
        return 'Study';
      case SprintCategory.coding:
        return 'Coding';
      case SprintCategory.reading:
        return 'Reading';
      case SprintCategory.fitness:
        return 'Fitness';
      case SprintCategory.custom:
      default:
        return 'Custom';
    }
  }
}
