import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../features/block_themes/services/block_theme_manager.dart';
import '../../features/shop/services/shop_manager.dart';
import '../localization/locale_manager.dart';
import '../storage/app_prefs.dart';
import '../utils/app_logger.dart';

class IapProductInfo {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final int? grantedShards;
  final bool isConsumable;
  final String fallbackPrice;

  const IapProductInfo({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    this.grantedShards,
    this.isConsumable = true,
    required this.fallbackPrice,
  });

  String get title =>
      LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get description =>
      LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;
}

class IapService extends ChangeNotifier {
  static final IapService instance = IapService._();
  IapService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isLoading = false;
  bool _hasNoAds = false;
  Map<String, ProductDetails> _products = {};
  String? _lastError;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  bool get hasNoAds => _hasNoAds;
  Map<String, ProductDetails> get products => _products;
  String? get lastError => _lastError;

  static const List<IapProductInfo> catalog = [
    IapProductInfo(
      id: 'shards_tier1_500',
      titleTr: 'Çırak Kesesi',
      titleEn: "Apprentice Pouch",
      descriptionTr: '500 Altın Şarapnel kazandırır.',
      descriptionEn: 'Grants 500 Gold Shards.',
      icon: '💰',
      grantedShards: 500,
      isConsumable: true,
      fallbackPrice: '29,99 ₺',
    ),
    IapProductInfo(
      id: 'shards_tier2_1500',
      titleTr: 'Maceracı Sandığı',
      titleEn: "Adventurer Chest",
      descriptionTr: '1.500 Altın Şarapnel (+%20 Bonus) kazandırır.',
      descriptionEn: 'Grants 1,500 Gold Shards (+20% Bonus).',
      icon: '🎁',
      grantedShards: 1500,
      isConsumable: true,
      fallbackPrice: '79,99 ₺',
    ),
    IapProductInfo(
      id: 'shards_tier3_5000',
      titleTr: 'Kadim Hazine',
      titleEn: "Ancient Vault",
      descriptionTr: '5.000 Altın Şarapnel (+%50 Dev Bonus) kazandırır.',
      descriptionEn: 'Grants 5,000 Gold Shards (+50% Huge Bonus).',
      icon: '👑',
      grantedShards: 5000,
      isConsumable: true,
      fallbackPrice: '199,99 ₺',
    ),
    IapProductInfo(
      id: 'no_ads_lifetime',
      titleTr: 'Reklamsız Hayat (VIP)',
      titleEn: 'No Ads Lifetime (VIP)',
      descriptionTr: 'Araya giren tüm reklamları sonsuza kadar kaldırır!',
      descriptionEn: 'Permanently removes all interstitial ads!',
      icon: '🚫',
      isConsumable: false,
      fallbackPrice: '49,99 ₺',
    ),
    IapProductInfo(
      id: 'battle_pass_premium',
      titleTr: 'Premium Savaş Bileti',
      titleEn: 'Premium Battle Pass',
      descriptionTr: 'Tüm sezon boyunca özel ejderha ödül yolunu açar.',
      descriptionEn: 'Unlocks the premium dragon reward track for the entire season.',
      icon: '🎫',
      isConsumable: false,
      fallbackPrice: '99,99 ₺',
    ),
  ];

  Future<void> initialize() async {
    await AppPrefs.instance.init();
    _hasNoAds = AppPrefs.instance.getBool(AppPrefs.kIapNoAds) ?? false;
    if (_hasNoAds) {
      await ShopManager.instance.syncVipFromIap(true);
    }

    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        AppLog.warn('IAP', 'IAP Store is not available on this device');
        notifyListeners();
        return;
      }

      final Set<String> productIds = catalog.map((p) => p.id).toSet();
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        AppLog.warn('IAP', 'IAP Products not found in Play Console: ${response.notFoundIDs}');
      }

      _products = {for (var p in response.productDetails) p.id: p};

      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) => AppLog.error('IAP purchaseStream', error),
      );
    } catch (e) {
      AppLog.error('IAP', 'IAP initialization failed: $e');
    }

    notifyListeners();
  }

  /// Starts the real Play Billing flow. Never grants items without a verified purchase.
  /// Returns true if the store UI was launched; delivery happens via [purchaseStream].
  Future<bool> buyProduct(String productId) async {
    _lastError = null;

    final catalogMatches = catalog.where((item) => item.id == productId);
    if (catalogMatches.isEmpty) {
      _lastError = 'Unknown product';
      AppLog.warn('IAP', 'Unknown product id: $productId');
      notifyListeners();
      return false;
    }
    final catalogItem = catalogMatches.first;

    if (!_isAvailable) {
      _lastError = 'Store unavailable. Check Google Play and try again.';
      AppLog.warn('IAP', 'Store offline — refusing free grant for $productId');
      notifyListeners();
      return false;
    }

    final productDetails = _products[productId];
    if (productDetails == null) {
      _lastError = 'Product not available in Play Console yet.';
      AppLog.warn('IAP', 'ProductDetails missing for $productId — refusing free grant');
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      if (catalogItem.isConsumable) {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      _lastError = 'Billing failed to open.';
      AppLog.error('IAP', 'Failed to launch billing flow for $productId: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _lastError = 'Store unavailable. Check Google Play and try again.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _lastError = 'Restore failed.';
      AppLog.error('IAP', 'Failed to restore purchases: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getLocalizedPrice(String productId) {
    if (_products.containsKey(productId)) {
      return _products[productId]!.price;
    }
    final item = catalog.firstWhere((p) => p.id == productId, orElse: () => catalog.first);
    return item.fallbackPrice;
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _isLoading = true;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final matched = catalog.where((p) => p.id == purchaseDetails.productID);
          if (matched.isEmpty) {
            AppLog.warn('IAP', 'Purchased unknown product: ${purchaseDetails.productID}');
          } else {
            await _deliverProduct(matched.first);
          }

          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          _isLoading = false;
          notifyListeners();
          break;

        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _lastError = purchaseDetails.error?.message ?? 'Purchase cancelled.';
          AppLog.warn('IAP', 'Purchase cancelled or error: ${purchaseDetails.error}');
          _isLoading = false;
          notifyListeners();
          break;
      }
    }
  }

  Future<void> _deliverProduct(IapProductInfo item) async {
    if (item.grantedShards != null && item.grantedShards! > 0) {
      await ShopManager.instance.addShards(item.grantedShards!);
      AppLog.info('IAP', 'Delivered ${item.grantedShards} shards for ${item.id}');
    }

    if (item.id == 'no_ads_lifetime') {
      _hasNoAds = true;
      await AppPrefs.instance.setBool(AppPrefs.kIapNoAds, true);
      await ShopManager.instance.syncVipFromIap(true);
      BlockThemeManager.instance.checkAutoProgressionUnlocks();
      AppLog.info('IAP', 'No-Ads lifetime unlocked + VIP themes synced!');
    }

    if (item.id == 'battle_pass_premium') {
      // Entitlement placeholder until Battle Pass domain ships.
      await AppPrefs.instance.setBool(AppPrefs.kIapBattlePass, true);
      AppLog.info('IAP', 'Battle Pass premium flag stored (no UI track yet).');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
