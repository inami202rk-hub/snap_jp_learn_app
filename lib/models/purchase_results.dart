/// Result types for purchase operations
sealed class PurchaseResult {
  const PurchaseResult();
}

/// Successful purchase result
class PurchaseSuccess extends PurchaseResult {
  final String productId;
  final String? transactionId;

  const PurchaseSuccess({
    required this.productId,
    this.transactionId,
  });
}

/// Purchase was cancelled by user
class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

/// Purchase is pending (waiting for approval)
class PurchasePending extends PurchaseResult {
  final String? reason;

  const PurchasePending({this.reason});
}

/// Purchase failed due to network issues
class PurchaseNetworkError extends PurchaseResult {
  final String? message;

  const PurchaseNetworkError({this.message});
}

/// User already owns this product
class PurchaseAlreadyOwned extends PurchaseResult {
  final String productId;

  const PurchaseAlreadyOwned({required this.productId});
}

/// Purchase failed for unknown reason
class PurchaseFailed extends PurchaseResult {
  final String? errorCode;
  final String? message;

  const PurchaseFailed({this.errorCode, this.message});
}

/// Restore result types
sealed class RestoreResult {
  const RestoreResult();
}

/// Restore successful with purchased items
class RestoreSuccess extends RestoreResult {
  final List<String> restoredProductIds;

  const RestoreSuccess({required this.restoredProductIds});
}

/// Restore successful but no items found
class RestoreNoItems extends RestoreResult {
  const RestoreNoItems();
}

/// Restore failed due to network issues
class RestoreNetworkError extends RestoreResult {
  final String? message;

  const RestoreNetworkError({this.message});
}

/// Restore failed for unknown reason
class RestoreFailed extends RestoreResult {
  final String? errorCode;
  final String? message;

  const RestoreFailed({this.errorCode, this.message});
}
