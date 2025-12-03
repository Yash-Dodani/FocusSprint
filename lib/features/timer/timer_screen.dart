import 'dart:async';
import 'dart:math' as math;
import '../../services/notification_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/models/sprint.dart';
import '../../providers/sprint_provider.dart';
import '../../services/ad_service.dart';

class TimerScreen extends StatefulWidget {
  final Sprint sprint;

  const TimerScreen({super.key, required this.sprint});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  late int _secondsLeft;
  late final int _totalSeconds;
  late final int _notificationId;
  bool _isPaused = false;
  BannerAd? _banner; // timer screen banner

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.sprint.durationMinutes * 60;
    _secondsLeft = _totalSeconds;
    _notificationId = widget.sprint.id.hashCode & 0x7FFFFFFF;

    print(
      '[TIMER] Starting sprint "${widget.sprint.title}" '
      'for $_totalSeconds seconds, notifId=$_notificationId',
    );
    _startTimer();
    _scheduleEndAlarm();

    // Ads
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

  Future<void> _scheduleEndAlarm() async {
    print('[TIMER] Requesting ALARM schedule for $_secondsLeft seconds');
    await NotificationService.instance.scheduleSprintEndAlarm(
      id: _notificationId,
      secondsFromNow: _secondsLeft,
      title: widget.sprint.title,
    );
  }

  Future<void> _cancelEndAlarm() async {
    await NotificationService.instance.cancelNotification(_notificationId);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_secondsLeft <= 1) {
        print('[TIMER] Countdown reached zero (local timer)');
        timer.cancel();
        _onCompleted();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _onCompleted() async {
    print('[TIMER] onCompleted() called');

    await _cancelEndAlarm();
    await NotificationService.instance.showSprintEndAlarmNow(
      id: _notificationId,
      title: widget.sprint.title,
    );
    final provider = context.read<SprintProvider>();
    await provider.completeSprint(widget.sprint.id);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(
        onDoubleXp: () {
          AdService.instance.showRewardedAd(
            onEarnedReward: () => provider.doubleLastSprintXp(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _banner?.dispose();
    _cancelEndAlarm();
    super.dispose();
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (widget.sprint.durationMinutes * 60).clamp(1, 999999);
    final fraction = _secondsLeft / totalSeconds;

   
    final size = MediaQuery.of(context).size;
    final double ringSize = math.min(size.width, size.height * 0.6) * 0.8;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(height: 20),
              Text(
                widget.sprint.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay with it. No distractions. 💪',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // ------------- BIG NEON RING + CENTERED TIME -------------
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: fraction),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) {
                      return NeonProgressRing(
                        size: ringSize,
                        progress: value,
                        child: Text(
                          _timeLabel,
                          style: const TextStyle(
                            fontSize: 56, // big time text
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ------------- ANIMATED BUTTONS -------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: _isPaused ? 'Resume' : 'Pause',
                    icon: _isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    filled: true,
                    onTap: () {
                      setState(() => _isPaused = !_isPaused);
                    },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    label: 'Give up',
                    icon: Icons.close_rounded,
                    filled: false,
                    onTap: () async {
                      final shouldQuit = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Give up?'),
                          content: const Text(
                            'Your sprint progress will be lost. Are you sure you want to stop?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('No, continue'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Yes, stop'),
                            ),
                          ],
                        ),
                      );

                      if (shouldQuit == true && mounted) {
                        await _cancelEndAlarm();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ------------- TIMER SCREEN BANNER AD -------------
      bottomNavigationBar: SafeArea(
        child: _banner == null
            ? const SizedBox.shrink()
            : Container(
                height: _banner!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _banner!),
              ),
      ),
    );
  }
}

/// Big, thin, neon-like circular progress ring
class NeonProgressRing extends StatelessWidget {
  final double size;
  final double progress; // 0..1
  final Widget child;

  const NeonProgressRing({
    super.key,
    required this.size,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _NeonRingPainter(clamped),
          ),
          child,
        ],
      ),
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final double progress;

  _NeonRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;

    // base ring
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.white10;

    canvas.drawCircle(center, radius, basePaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [Color(0xFF00E5FF), Color(0xFF00B0FF), Color(0xFF00E5FF)],
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ---------- Animated pill button ----------
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.94);
  void _up([_]) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.filled
        ? const Color(0xFF5B2EFF)
        : Colors.transparent;
    final fgColor = widget.filled ? Colors.white : const Color(0xFF5B2EFF);

    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(widget.filled ? 1 : 0.05),
            borderRadius: BorderRadius.circular(999),
            border: widget.filled
                ? null
                : Border.all(color: const Color(0xFF5B2EFF), width: 1),
            boxShadow: widget.filled
                ? [
                    BoxShadow(
                      color: const Color(0xFF5B2EFF).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: fgColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(color: fgColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Animated completion dialog ----------
class _CompletionDialog extends StatelessWidget {
  final VoidCallback onDoubleXp;

  const _CompletionDialog({required this.onDoubleXp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Sprint completed 🎉'),
              content: const Text(
                'Nice work! You earned 10 XP.\n\nWatch a short ad to double your XP?',
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // dialog
                    Navigator.pop(context); // timer -> home
                  },
                  child: const Text('No thanks'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDoubleXp();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Double XP'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
