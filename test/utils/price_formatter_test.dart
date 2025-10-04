import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:snap_jp_learn_app/utils/price_formatter.dart';

void main() {
  group('PriceFormatter Tests', () {
    test('formatPrice returns correct format for monthly subscription', () {
      final product = ProductDetails(
        id: 'pro_monthly',
        title: 'Monthly Pro',
        description: 'Monthly subscription',
        price: '¥300',
        rawPrice: 300.0,
        currencyCode: 'JPY',
        currencySymbol: '¥',
      );

      final formattedPrice = PriceFormatter.formatPrice(product);
      expect(formattedPrice, equals('¥300/month'));
    });

    test('formatPrice returns correct format for lifetime purchase', () {
      final product = ProductDetails(
        id: 'pro_lifetime',
        title: 'Lifetime Pro',
        description: 'One-time purchase',
        price: '¥2,980',
        rawPrice: 2980.0,
        currencyCode: 'JPY',
        currencySymbol: '¥',
      );

      final formattedPrice = PriceFormatter.formatPrice(product);
      expect(formattedPrice, equals('¥2,980 (one-time)'));
    });

    test('getPriceDescription returns full price description', () {
      final product = ProductDetails(
        id: 'pro_monthly',
        title: 'Monthly Pro',
        description: 'Monthly subscription',
        price: '¥300',
        rawPrice: 300.0,
        currencyCode: 'JPY',
        currencySymbol: '¥',
      );

      final description = PriceFormatter.getPriceDescription(product);
      expect(description, equals('¥300/month JPY'));
    });

    testWidgets('buildPriceWidget creates correct widget', (WidgetTester tester) async {
      final product = ProductDetails(
        id: 'pro_monthly',
        title: 'Monthly Pro',
        description: 'Monthly subscription',
        price: '¥300',
        rawPrice: 300.0,
        currencyCode: 'JPY',
        currencySymbol: '¥',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriceFormatter.buildPriceWidget(product),
          ),
        ),
      );

      // Verify price is displayed
      expect(find.text('¥300/month'), findsOneWidget);
      expect(find.text('JPY'), findsOneWidget);
      expect(find.text('Billed monthly'), findsOneWidget);
    });

    testWidgets('buildPriceWidget for lifetime purchase', (WidgetTester tester) async {
      final product = ProductDetails(
        id: 'pro_lifetime',
        title: 'Lifetime Pro',
        description: 'One-time purchase',
        price: '¥2,980',
        rawPrice: 2980.0,
        currencyCode: 'JPY',
        currencySymbol: '¥',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriceFormatter.buildPriceWidget(product),
          ),
        ),
      );

      // Verify price is displayed
      expect(find.text('¥2,980 (one-time)'), findsOneWidget);
      expect(find.text('JPY'), findsOneWidget);
      // Lifetime should not show "Billed monthly"
      expect(find.text('Billed monthly'), findsNothing);
    });

    test('formatRawPrice formats raw price correctly', () {
      final formatted = PriceFormatter.formatRawPrice('300.0', 'JPY');
      expect(formatted, equals('300.00 JPY'));
    });

    test('formatRawPrice handles invalid input gracefully', () {
      final formatted = PriceFormatter.formatRawPrice('invalid', 'JPY');
      expect(formatted, equals('invalid JPY'));
    });

    test('getTaxNote returns tax information', () {
      final taxNote = PriceFormatter.getTaxNote();
      expect(taxNote, isNotEmpty);
      expect(taxNote, contains('tax'));
    });
  });
}
