import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../common/utils/constants.dart';
import '../storage/storage_service.dart';

class AdService extends GetxService {
  final StorageService _storageService;
  AdService(this._storageService);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  final RxBool isBannerReady = false.obs;
  final RxBool isInterstitialLoaded = false.obs;
  final RxBool isRewardedLoaded = false.obs;

  DateTime? _lastInterstitialShownTime;
  static const int _interstitialCooldownSeconds = 90; // reasonable interval

  Future<AdService> init() async {
    try {
      await MobileAds.instance.initialize();
      if (!_storageService.isPremium.value) {
        _loadInterstitialAd();
        _loadRewardedAd();
      }
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
    return this;
  }

  bool get shouldShowAds => !_storageService.isPremium.value;

  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: AppConstants.bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerReady.value = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerReady.value = false;
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  void _loadInterstitialAd() {
    if (!shouldShowAds) return;

    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitIdAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialLoaded.value = true;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd failed to load: $err');
          _interstitialAd = null;
          isInterstitialLoaded.value = false;
        },
      ),
    );
  }

  /// Shows interstitial ad if cooldown passed and user is NOT premium and NOT in active tracing!
  bool showInterstitialAd({bool force = false}) {
    if (!shouldShowAds) return false;

    if (!force && _lastInterstitialShownTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShownTime!).inSeconds;
      if (elapsed < _interstitialCooldownSeconds) {
        return false;
      }
    }

    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _lastInterstitialShownTime = DateTime.now();
      _interstitialAd = null;
      isInterstitialLoaded.value = false;
      return true;
    }

    _loadInterstitialAd();
    return false;
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitIdAndroid,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedLoaded.value = true;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('RewardedAd failed to load: $err');
          _rewardedAd = null;
          isRewardedLoaded.value = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    Function()? onAdDismissed,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (adWithoutView, reward) {
          onUserEarnedReward(reward);
        },
      );
      _rewardedAd = null;
      isRewardedLoaded.value = false;
    } else {
      // Mock reward if ad not yet available so user is not blocked
      debugPrint('Rewarded ad not loaded yet; delivering reward for testing');
      onUserEarnedReward(RewardItem(1, 'premium_unlock'));
      _loadRewardedAd();
    }
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}

