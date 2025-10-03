import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/billing.dart';

/// 購入結果
class PurchaseResult {
  final bool isSuccess;
  final String? errorMessage;
  final PurchaseDetails? purchase;

  PurchaseResult({
    required this.isSuccess,
    this.errorMessage,
    this.purchase,
  });
}

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
        PurchaseResult(isSuccess: false, errorMessage: error.toString()),
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

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(BillingConstants.productIds);

      if (response.error != null) {
        throw Exception('Failed to load products: ${response.error}');
      }

      return response.productDetails;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// 商品を購入
  Future<PurchaseResult> buy(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        return PurchaseResult(
          isSuccess: false,
          errorMessage: BillingConstants.errorPurchaseFailed,
        );
      }

      // 購入結果は _onPurchaseUpdated で処理される
      return PurchaseResult(isSuccess: true);
    } catch (e) {
      return PurchaseResult(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 購入を復元
  Future<void> restore() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          isSuccess: false,
          errorMessage: BillingConstants.errorRestoreFailed,
        ),
      );
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
        // 保留中（何もしない）
        break;
      case PurchaseStatus.purchased:
        _purchaseController.add(
          PurchaseResult(
            isSuccess: true,
            purchase: purchaseDetails,
          ),
        );
        _completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.error:
        _purchaseController.add(
          PurchaseResult(
            isSuccess: false,
            errorMessage: purchaseDetails.error?.message ??
                BillingConstants.errorPurchaseFailed,
            purchase: purchaseDetails,
          ),
        );
        break;
      case PurchaseStatus.restored:
        _purchaseController.add(
          PurchaseResult(
            isSuccess: true,
            purchase: purchaseDetails,
          ),
        );
        _completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.canceled:
        _purchaseController.add(
          PurchaseResult(
            isSuccess: false,
            errorMessage: BillingConstants.errorPurchaseCancelled,
            purchase: purchaseDetails,
          ),
        );
        break;
    }
  }

  /// 購入を完了
  void _completePurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// リソースを解放
  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
