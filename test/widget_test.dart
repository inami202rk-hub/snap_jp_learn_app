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
}
