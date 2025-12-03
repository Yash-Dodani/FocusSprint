import 'package:flutter/material.dart';
import 'package:focusSprint/features/about/about_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../providers/sprint_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/ad_service.dart';
import '../create_sprint/create_sprint_screen.dart';
import '../stats/stats_screen.dart';
import '../shared/today_progress_card.dart';
import '../shared/sprint_tile.dart';
import '../xp_shop/xp_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    AdService.instance.init();

    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _banner = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sprintProvider = context.watch<SprintProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final completed = sprintProvider.completedCount;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final target = sprintProvider.dailyTarget;
    final progress = sprintProvider.todayProgress;
    final xp = sprintProvider.xp;

    final totalMinutesToday = sprintProvider.todaySprints.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );

    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ------------ GRADIENT HEADER ------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF21143F), Color(0xFF3C2A73)]
                      : const [Color(0xFF5B2EFF), Color(0xFF8E5BFF)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FocusSprint',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  _AnimatedQuote(),
                ],
              ),
            ),

            // ------------ SUMMARY + XP / THEME ROW ------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // progress text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You've done $completed / $target sprints today",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalMinutesToday min focused today ⏱️',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // XP card + circular icons
                  _XpAndActions(
                    xp: xp,
                    isDark: isDark,
                    onOpenShop: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const XpShopScreen()),
                      );
                    },
                    onOpenStats: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                    onToggleTheme: () => themeProvider.toggleMode(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ------------ BODY ------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                children: [
                  TodayProgressCard(progress: progress),
                  const SizedBox(height: 18),
                  Text(
                    "Today's sprints",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sprintProvider.todaySprints.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No sprints yet. Start your first one! 🚀',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    )
                  else
                    ...sprintProvider.todaySprints
                        .map((sprint) => SprintTile(sprint: sprint))
                        .toList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // ------------ START BUTTON + BANNER ------------
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: PrimaryButton(
                label: 'Start sprint',
                fullWidth: true,
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSprintScreen(),
                    ),
                  );
                },
              ),
            ),
            if (_banner != null)
              Container(
                height: _banner!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _banner!),
              ),
          ],
        ),
      ),
    );
  }
}

// XP chip + small round icon buttons row
class _XpAndActions extends StatelessWidget {
  final int xp;
  final bool isDark;
  final VoidCallback onOpenShop;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenStats;

  const _XpAndActions({
    required this.xp,
    required this.isDark,
    required this.onOpenShop,
    required this.onToggleTheme,
    required this.onOpenStats,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF19192A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black12;

    return Row(
      children: [
        GestureDetector(
          onTap: onOpenShop,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$xp XP',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.insights_rounded,
          isDark: isDark,
          onTap: onOpenStats,
        ),
        const SizedBox(width: 6),
        _CircleIconButton(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          isDark: isDark,
          onTap: onToggleTheme,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF19192A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black12;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

/// Bigger animated quote with emoji & slide
class _AnimatedQuote extends StatefulWidget {
  const _AnimatedQuote();

  @override
  State<_AnimatedQuote> createState() => _AnimatedQuoteState();
}

class _AnimatedQuoteState extends State<_AnimatedQuote> {
  static const _quotes = [
    'Deep focus beats long hours. 🧠',
    'One sprint now > ten “later”. 🚀',
    'Tiny sprints today, massive progress tomorrow. 🌱',
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 7));
      if (!mounted) break;
      setState(() {
        _index = (_index + 1) % _quotes.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text(
        _quotes[_index],
        key: ValueKey(_index),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
