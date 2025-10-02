// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snap_jp_learn_app/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnapJpLearnApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the home page is displayed
    expect(find.text('ホーム画面'), findsOneWidget);

    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify all navigation items are present
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Navigation between tabs works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnapJpLearnApp());
    await tester.pumpAndSettle();

    // Tap on Settings tab in the bottom navigation
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings page is displayed
    expect(find.text('学習設定'), findsOneWidget);

    // Tap on Stats tab
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();

    // Verify Stats page is displayed
    expect(find.text('統計画面'), findsOneWidget);

    // Tap on Home tab
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // Verify Home page is displayed
    expect(find.text('ホーム画面'), findsOneWidget);
  });

  testWidgets('OCR test button works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnapJpLearnApp());
    await tester.pumpAndSettle();

    // Scroll down to make sure the OCR button is visible
    await tester.scrollUntilVisible(
      find.text('OCRテスト'),
      500.0,
      scrollable: find.byType(Scrollable).first,
    );

    // Verify OCR test button is present
    expect(find.text('OCRテスト'), findsOneWidget);

    // Tap OCR test button
    await tester.tap(find.text('OCRテスト'), warnIfMissed: false);
    await tester.pump(); // Start the async operation

    // Wait for loading dialog to appear
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the OCR operation to complete
    await tester.pumpAndSettle();

    // Verify OCR result dialog appears
    expect(find.text('OCR結果'), findsOneWidget);
    expect(find.text('抽出されたテキスト:'), findsOneWidget);

    // Verify that some mock text is displayed (not empty)
    final textWidgets = tester.widgetList<Text>(find.byType(Text));
    final hasNonEmptyText = textWidgets.any((widget) {
      final text = widget.data ?? '';
      return text.isNotEmpty && 
             text != 'OCR結果' && 
             text != '抽出されたテキスト:' && 
             text != '閉じる' && 
             text != '学習に追加' &&
             text != 'テキストが検出されませんでした';
    });
    expect(hasNonEmptyText, isTrue);

    // Close the dialog
    await tester.tap(find.text('閉じる'));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.text('OCR結果'), findsNothing);
  });
}
