import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../common/utils/constants.dart';
import '../storage/storage_service.dart';

class PurchaseService extends GetxService {
  final StorageService _storageService;
  PurchaseService(this._storageService);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final RxBool isStoreAvailable = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isLoading = false.obs;
  final RxString statusMessage = ''.obs;

  Future<PurchaseService> init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP purchaseStream error: $error'),
    );

    await checkStoreAvailabilityAndLoadProducts();
    return this;
  }

  Future<void> checkStoreAvailabilityAndLoadProducts() async {
    try {
      final available = await _iap.isAvailable();
      isStoreAvailable.value = available;

      if (available) {
        final ProductDetailsResponse response = await _iap.queryProductDetails(
          AppConstants.kAllProductIds.toSet(),
        );

        if (response.error != null) {
          debugPrint('Error querying product details: ${response.error}');
        }

        products.assignAll(response.productDetails);
      }
    } catch (e) {
      debugPrint('Error checking IAP store: $e');
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    try {
      isLoading.value = true;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Buy product error: $e');
      statusMessage.value = 'Failed to initiate purchase: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      statusMessage.value = 'Restore failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
          statusMessage.value = 'Purchase error: ${purchaseDetails.error?.message}';
          isLoading.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Validated real purchase from billing
          _storageService.setPremium(true);
          statusMessage.value = 'Premium features unlocked!';
          isLoading.value = false;
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

