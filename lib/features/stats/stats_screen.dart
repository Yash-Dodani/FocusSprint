import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sprint_provider.dart';
import '../shared/sprint_tile.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SprintProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    final xp = provider.xp;
    final streak = provider.streak;
    final sprintsToday = provider.todaySprints.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Your stats')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TOP SUMMARY CARD (ANIMATED) ----------
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF19192A) : Colors.white,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatColumn(
                      label: 'XP',
                      value: '$xp',
                      icon: '⭐',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _StatColumn(
                      label: 'Sprints today',
                      value: '$sprintsToday',
                      icon: '⚡',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _StatColumn(
                      label: 'Streak',
                      value: '$streak',
                      icon: '🔥',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Today's sprints",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (provider.todaySprints.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'You have no sprints yet today. Start one from the home screen! 🚀',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: provider.todaySprints.length,
                  itemBuilder: (context, index) {
                    final sprint = provider.todaySprints[index];
                    return SprintTile(sprint: sprint);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color textPrimary;
  final Color textSecondary;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
      ],
    );
  }
}
