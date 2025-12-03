import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  bool _initialized = false;

  // true => Google test ads (recommended for dev / competition)
  static const bool useTestAds = true;

  // --------- IDs ---------
  // ↓ yahan apne REAL ad unit IDs dal sakte ho
  static String get bannerAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/6300978111' // test banner
      : 'ca-app-pub-XXXXXXX/YYYYYYY'; // TODO: apna banner ad unit id

  static String get rewardedAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/5224354917' // test rewarded
      : 'ca-app-pub-XXXXXXX/ZZZZZZZ'; // TODO: apna rewarded ad unit id

  // --------- INIT ---------
  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadRewarded();
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({required VoidCallback onEarnedReward}) {
    final ad = _rewardedAd;
    if (ad == null) {
      // fallback – XP double without ad
      onEarnedReward();
      _loadRewarded();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded failed to show: $error');
        ad.dispose();
        _loadRewarded();
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      onEarnedReward();
    });

    _rewardedAd = null;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
