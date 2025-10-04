import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';
import '../constants/billing.dart';
import '../utils/price_formatter.dart';
import '../models/purchase_results.dart';
import '../l10n/strings_en.dart';

/// Pro機能の課金画面
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final PurchaseService _purchaseService = PurchaseService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePurchase();
    _loadProducts();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  /// 購入サービスを初期化
  Future<void> _initializePurchase() async {
    try {
      await _purchaseService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = '購入サービスを初期化できませんでした: $e';
        _isLoading = false;
      });
    }
  }

  /// 商品を読み込み
  Future<void> _loadProducts() async {
    try {
      final products = await _purchaseService.loadProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '商品を読み込めませんでした: $e';
        _isLoading = false;
      });
    }
  }

  /// 商品を購入
  Future<void> _purchaseProduct(ProductDetails product) async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final result = await _purchaseService.buy(product);

      setState(() {
        _isPurchasing = false;
      });

      switch (result) {
        case PurchaseSuccess():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.purchaseSuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        case PurchaseCancelled():
          setState(() {
            _errorMessage = AppStrings.purchaseCancelledMessage;
          });
        case PurchaseNetworkError():
          setState(() {
            _errorMessage = AppStrings.networkErrorMessage;
          });
        case PurchaseAlreadyOwned():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.purchaseAlreadyOwnedMessage),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        case PurchasePending():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.purchasePendingMessage),
              backgroundColor: Colors.orange,
            ),
          );
        case PurchaseFailed():
          setState(() {
            _errorMessage = AppStrings.purchaseFailedMessage;
          });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Purchase error: $e';
        _isPurchasing = false;
      });
    }
  }

  /// 購入を復元
  Future<void> _restorePurchases() async {
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final result = await _purchaseService.restore();

      setState(() {
        _isRestoring = false;
      });

      switch (result) {
        case RestoreSuccess():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.restoreSuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        case RestoreNoItems():
          setState(() {
            _errorMessage = AppStrings.restoreNoItemsMessage;
          });
        case RestoreNetworkError():
          setState(() {
            _errorMessage = AppStrings.networkErrorMessage;
          });
        case RestoreFailed():
          setState(() {
            _errorMessage = AppStrings.restoreFailedMessage;
          });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Restore error: $e';
        _isRestoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro機能'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _products.isEmpty
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  /// エラー状態を表示
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadProducts();
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  /// メインコンテンツを表示
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFeatures(),
          const SizedBox(height: 32),
          _buildProducts(),
          const SizedBox(height: 24),
          _buildRestoreButton(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  /// ヘッダー部分
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚀 Pro機能で学習を加速',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '制限なしで日本語学習を続けましょう',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// 機能一覧
  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BillingConstants.proFeaturesTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...BillingConstants.proFeatures.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// 商品一覧
  Widget _buildProducts() {
    if (_products.isEmpty) {
      return const Center(
        child: Text('商品が見つかりません'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'プランを選択',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._products.map((product) => _buildProductCard(product)),
      ],
    );
  }

  /// 商品カード
  Widget _buildProductCard(ProductDetails product) {
    final isMonthly = product.id == BillingConstants.proMonthlyId;
    final isRecommended = isMonthly; // 月額プランを推奨

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isRecommended
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isMonthly
                        ? BillingConstants.proMonthlyName
                        : BillingConstants.proLifetimeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '推奨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isMonthly
                  ? BillingConstants.proMonthlyDescription
                  : BillingConstants.proLifetimeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceFormatter.buildPriceWidget(product),
                ElevatedButton(
                  onPressed:
                      _isPurchasing ? null : () => _purchaseProduct(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('購入'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 復元ボタン
  Widget _buildRestoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isPurchasing || _isRestoring ? null : _restorePurchases,
        child: _isRestoring
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(AppStrings.restorePurchases),
      ),
    );
  }

  /// エラーメッセージ
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }
}
