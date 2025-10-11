import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snap_jp_learn_app/core/entitlements.dart';
import 'package:snap_jp_learn_app/widgets/lock_sheet.dart';
import 'package:snap_jp_learn_app/services/purchase_service.dart';
import 'package:snap_jp_learn_app/services/entitlement_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snap_jp_learn_app/generated/app_localizations.dart';

void main() {
  group('LockSheet', () {
    late UsageStats testStats;
    late MockPurchaseService mockPurchaseService;
    late MockEntitlementService mockEntitlementService;

    setUp(() {
      testStats = UsageStats(
        savedPostsCount: 50,
        todayOcrCount: 0,
        createdCardsCount: 0,
        reviewSessionsCount: 0,
        lastOcrDate: DateTime.now(),
      );

      mockPurchaseService = MockPurchaseService();
      mockEntitlementService = MockEntitlementService();
    });

    Widget createTestWidget({
      required Feature lockedFeature,
      VoidCallback? onUnlocked,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ja', ''),
        ],
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<PurchaseService>.value(
                value: mockPurchaseService),
            ChangeNotifierProvider<EntitlementService>.value(
                value: mockEntitlementService),
          ],
          child: Scaffold(
            body: LockSheet(
              lockedFeature: lockedFeature,
              usageStats: testStats,
              onUnlocked: onUnlocked,
            ),
          ),
        ),
      );
    }

    testWidgets('should display lock icon and title',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Storage Limit Reached'), findsOneWidget);
    });

    testWidgets('should display usage indicator for post storage',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      expect(find.text('Current Usage'), findsOneWidget);
      expect(find.text('50/50'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display Pro benefits section',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      expect(find.text('Pro Benefits'), findsOneWidget);
      expect(find.text('Unlimited posts and cards'), findsOneWidget);
      expect(find.text('Advanced OCR processing'), findsOneWidget);
      expect(find.text('Cloud backup & sync'), findsOneWidget);
      expect(find.text('Detailed statistics'), findsOneWidget);
      expect(find.text('Custom themes'), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('should call onUnlocked when upgrade button is tapped',
        (WidgetTester tester) async {
      bool unlockCalled = false;

      await tester.pumpWidget(createTestWidget(
        lockedFeature: Feature.postStorage,
        onUnlocked: () => unlockCalled = true,
      ));

      await tester.tap(find.text('Upgrade to Pro'));
      await tester.pumpAndSettle();

      // Should navigate to paywall (LockSheet should be dismissed)
      expect(find.byType(LockSheet), findsNothing);
    });

    testWidgets('should dismiss when cancel button is tapped',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(LockSheet), findsNothing);
    });

    testWidgets('should display correct title for OCR limit',
        (WidgetTester tester) async {
      final ocrStats = testStats.copyWith(todayOcrCount: 10);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<PurchaseService>.value(
                  value: mockPurchaseService),
              ChangeNotifierProvider<EntitlementService>.value(
                  value: mockEntitlementService),
            ],
            child: Scaffold(
              body: LockSheet(
                lockedFeature: Feature.ocrExecution,
                usageStats: ocrStats,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Daily OCR Limit Reached'), findsOneWidget);
    });

    testWidgets('should display correct title for card creation limit',
        (WidgetTester tester) async {
      final cardStats = testStats.copyWith(createdCardsCount: 500);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<PurchaseService>.value(
                  value: mockPurchaseService),
              ChangeNotifierProvider<EntitlementService>.value(
                  value: mockEntitlementService),
            ],
            child: Scaffold(
              body: LockSheet(
                lockedFeature: Feature.cardCreation,
                usageStats: cardStats,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Creation Limit Reached'), findsOneWidget);
    });

    testWidgets('should handle restore purchases', (WidgetTester tester) async {
      mockPurchaseService.setRestoreResult(true);

      await tester
          .pumpWidget(createTestWidget(lockedFeature: Feature.postStorage));

      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      // Should show loading dialog first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for restore to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Loading dialog should be dismissed
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

/// Mock PurchaseService for testing
class MockPurchaseService {
  bool _restoreResult = false;

  void setRestoreResult(bool result) {
    _restoreResult = result;
  }

  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _restoreResult;
  }
}

/// Mock EntitlementService for testing
class MockEntitlementService {
  Future<bool> checkEntitlementStatus() async {
    return false; // Default to free user
  }
}
