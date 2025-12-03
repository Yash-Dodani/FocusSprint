import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sprint_provider.dart';

class XpShopScreen extends StatelessWidget {
  const XpShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SprintProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    return Scaffold(
      appBar: AppBar(title: const Text('XP Lab')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'You currently have ${provider.xp} XP ⭐',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Finish focus sprints → earn XP → trade for boosts.',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Streak shield
            _XpTile(
              title: 'Streak Shield (Concept)',
              emoji: '🛡️',
              description:
                  'Spend 50 XP to protect your streak for one day, even if you miss. (Concept demo for judges).',
              cost: 50,
              onPressed: () {
                if (provider.spendXp(50)) {
                  _snack(
                    context,
                    'Streak Shield activated! (concept – will be implemented with notifications).',
                  );
                } else {
                  _notEnoughXp(context);
                }
              },
            ),
            const SizedBox(height: 12),

            // 2. Gift card – XP → “focus reward”
            _XpTile(
              title: 'Focus Gift Card',
              emoji: '🎁',
              description:
                  'Spend 80 XP to unlock a virtual “focus gift card” – a small celebratory moment in the stats screen (concept).',
              cost: 80,
              onPressed: () {
                if (provider.spendXp(80)) {
                  _snack(
                    context,
                    'Gift card unlocked! Show this in your pitch as a future reward system.',
                  );
                } else {
                  _notEnoughXp(context);
                }
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              'Future In-App Purchases (demo)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In the full Play Store release, users will be able to buy XP packs using Google Play Billing. '
              'This button is a non-payment prototype – it just calls addXpFromIap().',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 16),
            Center(
              child: _AnimatedGradientButton(
                label: 'Demo: Buy 100 XP (no real payment)',
                onTap: () {
                  provider.addXpFromIap(100);
                  _snack(
                    context,
                    '+100 XP added (demo only, no real billing).',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _notEnoughXp(BuildContext context) {
    _snack(context, 'Not enough XP yet. Finish more sprints! 💪');
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _XpTile extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final int cost;
  final VoidCallback onPressed;

  const _XpTile({
    required this.title,
    required this.description,
    required this.emoji,
    required this.cost,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF19192A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                '-$cost XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              _AnimatedGradientButton(
                label: 'Use',
                compact: true,
                onTap: onPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _AnimatedGradientButton({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.95);
  void _up([_]) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: Container(
          padding: widget.compact
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B2EFF), Color(0xFF8E5BFF)],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B2EFF).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
