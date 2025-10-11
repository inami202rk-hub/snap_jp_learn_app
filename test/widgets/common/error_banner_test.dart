import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/widgets/common/error_banner.dart';
import 'package:snap_jp_learn_app/core/ui_state.dart';

void main() {
  group('ErrorBanner', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided',
        (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('再試行'), findsOneWidget);

      await tester.tap(find.text('再試行'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('should display custom retry button text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
              onRetry: () {},
              retryButtonText: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('should display dismiss button when onDismiss is provided',
        (WidgetTester tester) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
              onDismiss: () => dismissCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('should use custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error message',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Test error message'),
          matching: find.byType(Container),
        ),
      );

      expect(container.color, equals(Colors.red));
    });
  });

  group('ErrorBannerWidget', () {
    testWidgets('should display child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              errorMessage: 'Test error message',
              child: const Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('should display child content when error message is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              errorMessage: null,
              child: const Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });
  });

  group('UiStateErrorBanner', () {
    testWidgets('should display child content for UiError state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiStateErrorBanner<String>(
              uiState: UiError<String>('Test error message'),
              child: const Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('should display child content for UiSuccess state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiStateErrorBanner<String>(
              uiState: UiSuccess<String>('Success data'),
              child: const Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('should display child content for UiLoading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiStateErrorBanner<String>(
              uiState: UiLoading<String>(),
              child: const Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });
  });
}
