import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ad_service.dart';
import '../../services/storage/storage_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final storageService = Get.find<StorageService>();
    if (storageService.isPremium.value) return;

    final adService = Get.find<AdService>();
    _bannerAd = adService.createBannerAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isLoaded = true);
      },
      onAdFailedToLoad: (error) {
        if (mounted) setState(() => _isLoaded = false);
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();

    return Obx(() {
      if (storageService.isPremium.value) {
        return const SizedBox.shrink();
      }

      if (!_isLoaded || _bannerAd == null) {
        return const SizedBox.shrink();
      }

      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(ad: _bannerAd!),
      );
    });
  }
}

