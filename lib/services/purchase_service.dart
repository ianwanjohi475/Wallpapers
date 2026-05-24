import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Google Play in-app purchases for the WC Wallpapers premium upgrade.
///
/// Setup steps (one-time, in Google Play Console):
///   1. Create app → Monetize → In-app products
///   2. Add product with ID: [kProductId]
///   3. Set price, title, description → Activate
///   4. Publish app to at least internal testing track
class PurchaseService extends ChangeNotifier {
  static final PurchaseService instance = PurchaseService._();
  PurchaseService._();

  static const kProductId = 'wc_wallpapers_premium';

  bool _storeAvailable = false;
  bool _loading = true;
  bool _purchasing = false;
  bool _isPremium = false;
  ProductDetails? _product;
  String? _error;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get storeAvailable => _storeAvailable;
  bool get loading => _loading;
  bool get purchasing => _purchasing;
  bool get isPremium => _isPremium;
  String get displayPrice => _product?.price ?? r'$0.99';
  String? get error => _error;
  ProductDetails? get product => _product;

  Future<void> initialize() async {
    _storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!_storeAvailable) {
      _loading = false;
      notifyListeners();
      return;
    }
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) {
        _error = 'Store connection error. Try again.';
        notifyListeners();
      },
    );
    await _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await InAppPurchase.instance
          .queryProductDetails({kProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.first;
      } else {
        // Product not found in Play Console — still show screen with fallback price
        debugPrint('IAP: product $kProductId not found in store');
      }
    } catch (e) {
      _error = 'Could not load product from store.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> buyPremium() async {
    if (_purchasing) return;
    if (!_storeAvailable) {
      _error = 'Store is not available on this device.';
      notifyListeners();
      return;
    }
    if (_product == null) {
      _error = 'Product not available. Try again later.';
      notifyListeners();
      return;
    }
    _purchasing = true;
    _error = null;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: _product!);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      // Result comes via purchaseStream → _onPurchaseUpdate
    } catch (e) {
      _error = 'Could not start purchase. Try again.';
      _purchasing = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (_purchasing) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _error = 'Could not restore purchases.';
      _loading = false;
      notifyListeners();
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremium(p);
          break;
        case PurchaseStatus.error:
          _error = p.error?.message ?? 'Purchase failed. Try again.';
          _purchasing = false;
          _loading = false;
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _purchasing = false;
          _loading = false;
          notifyListeners();
          break;
        default:
          break;
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  Future<void> _grantPremium(PurchaseDetails p) async {
    _isPremium = true;
    _purchasing = false;
    _loading = false;
    notifyListeners();

    // Persist premium status to Supabase profile
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'is_premium': true})
            .eq('id', uid);
      }
    } catch (e) {
      debugPrint('IAP: could not persist premium to Supabase: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
