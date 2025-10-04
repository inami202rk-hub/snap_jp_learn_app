import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/billing.dart';
import '../models/purchase_results.dart';

/// 課金サービス
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final StreamController<PurchaseResult> _purchaseController =
      StreamController<PurchaseResult>.broadcast();

  /// 購入結果のストリーム
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  /// 初期化
  Future<void> initialize() async {
    // 購入更新の監視
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) => _purchaseController.add(
        PurchaseFailed(message: error.toString()),
      ),
    );
  }

  /// 商品を読み込み
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        throw Exception('In-app purchase is not available');
      }

      final Set<String> productIds = {
        BillingConstants.proMonthlyId,
        BillingConstants.proLifetimeId,
      };

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        throw Exception('Products not found: ${response.notFoundIDs}');
      }

      return response.productDetails;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// 商品を購入
  Future<PurchaseResult> buy(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        return const PurchaseFailed(
          errorCode: 'PURCHASE_FAILED',
          message: 'Failed to initiate purchase',
        );
      }

      // 購入結果は _onPurchaseUpdated で処理される
      return const PurchaseSuccess(productId: '');
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return PurchaseNetworkError(message: e.toString());
      }
      return PurchaseFailed(message: e.toString());
    }
  }

  /// 購入を復元
  Future<RestoreResult> restore() async {
    try {
      await _inAppPurchase.restorePurchases();
      // 復元結果は購入ストリームで処理される
      return const RestoreSuccess(restoredProductIds: []);
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return RestoreNetworkError(message: e.toString());
      }
      return RestoreFailed(message: e.toString());
    }
  }

  /// 過去の購入を確認
  Future<RestoreResult> verifyPastPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      // 実際の検証は購入ストリームで処理される
      return const RestoreSuccess(restoredProductIds: []);
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return RestoreNetworkError(message: e.toString());
      }
      return RestoreFailed(message: e.toString());
    }
  }

  /// 購入更新の処理
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// 個別購入の処理
  void _handlePurchase(PurchaseDetails purchaseDetails) {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _purchaseController.add(PurchasePending(
          reason: 'Purchase is pending approval',
        ));
        break;
      case PurchaseStatus.purchased:
        _purchaseController.add(PurchaseSuccess(
          productId: purchaseDetails.productID,
          transactionId: purchaseDetails.purchaseID,
        ));
        break;
      case PurchaseStatus.error:
        _purchaseController.add(PurchaseFailed(
          errorCode: purchaseDetails.error?.code,
          message: purchaseDetails.error?.message,
        ));
        break;
      case PurchaseStatus.restored:
        _purchaseController.add(PurchaseSuccess(
          productId: purchaseDetails.productID,
          transactionId: purchaseDetails.purchaseID,
        ));
        break;
      case PurchaseStatus.canceled:
        _purchaseController.add(const PurchaseCancelled());
        break;
    }
  }

  /// リソースを解放
  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
