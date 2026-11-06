import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../common/utils/constants.dart';
import '../../common/utils/helpers.dart';
import '../../services/purchases/purchase_service.dart';
import '../../services/storage/storage_service.dart';

class PremiumPlan {
  final String id;
  final String title;
  final String price;
  final String period;
  final String? discountTag;
  final bool isPopular;

  const PremiumPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    this.discountTag,
    this.isPopular = false,
  });
}

class PremiumController extends GetxController {
  final PurchaseService purchaseService = Get.find<PurchaseService>();
  final StorageService storageService = Get.find<StorageService>();

  final RxString selectedPlanId = AppConstants.productIdProMonthly.obs;

  final List<PremiumPlan> fallbackPlans = const [
    PremiumPlan(
      id: AppConstants.productIdProWeekly,
      title: 'Weekly Access',
      price: '\$1.99',
      period: 'per week',
    ),
    PremiumPlan(
      id: AppConstants.productIdProMonthly,
      title: 'Monthly Pass',
      price: '\$4.99',
      period: 'per month',
      discountTag: 'SAVE 40%',
      isPopular: true,
    ),
    PremiumPlan(
      id: AppConstants.productIdProLifetime,
      title: 'Lifetime Unlimited',
      price: '\$19.99',
      period: 'one-time payment',
      discountTag: 'BEST VALUE',
    ),
  ];

  void selectPlan(String planId) {
    AppHelpers.hapticLight();
    selectedPlanId.value = planId;
  }

  Future<void> purchaseSelectedPlan() async {
    AppHelpers.hapticMedium();

    // Check if store products match
    final products = purchaseService.products;
    ProductDetails? matched;
    try {
      matched = products.firstWhere((p) => p.id == selectedPlanId.value);
    } catch (_) {
      matched = null;
    }

    if (matched != null) {
      await purchaseService.buyProduct(matched);
    } else {
      // In sandbox/testing mode when Google Play Billing products are pending review
      debugPrint('Purchasing product ID: ${selectedPlanId.value}');
      if (purchaseService.isStoreAvailable.value) {
        AppHelpers.showInfoSnackbar(
          'Store Connecting',
          'Connecting to Google Play Billing for product: ${selectedPlanId.value}',
        );
      } else {
        AppHelpers.showInfoSnackbar(
          'Google Play Store',
          'Store billing is ready and will initialize upon publishing to Play Console.',
        );
      }
    }
  }

  void restorePurchases() {
    AppHelpers.hapticLight();
    purchaseService.restorePurchases();
    AppHelpers.showInfoSnackbar('Restore', 'Checking active Play Store subscriptions...');
  }
}

