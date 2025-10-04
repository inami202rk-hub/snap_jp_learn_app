import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Utility class for price localization and formatting
class PriceFormatter {
  /// Format price with currency and period information
  static String formatPrice(ProductDetails product) {
    final price = product.price;

    // Handle subscription period
    String periodText = '';
    if (product.id.contains('monthly')) {
      periodText = '/month';
    } else if (product.id.contains('lifetime')) {
      periodText = ' (one-time)';
    }

    return '$price$periodText';
  }

  /// Get full price description with currency
  static String getPriceDescription(ProductDetails product) {
    final formattedPrice = formatPrice(product);
    final currencyCode = product.currencyCode;

    return '$formattedPrice $currencyCode';
  }

  /// Get price breakdown for display
  static Widget buildPriceWidget(ProductDetails product) {
    final formattedPrice = formatPrice(product);
    final currencyCode = product.currencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              formattedPrice,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              currencyCode,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        if (product.id.contains('monthly')) ...[
          const SizedBox(height: 4),
          Text(
            'Billed monthly',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Get tax information note based on platform
  static String getTaxNote() {
    // This is a simplified approach - in production you might want
    // to detect the platform and show appropriate tax information
    return 'Prices may include applicable taxes';
  }

  /// Format raw price with currency symbol
  static String formatRawPrice(String rawPrice, String currencyCode) {
    // Convert raw price string to double and format
    try {
      final price = double.parse(rawPrice);
      return '${price.toStringAsFixed(2)} $currencyCode';
    } catch (e) {
      return '$rawPrice $currencyCode';
    }
  }
}
