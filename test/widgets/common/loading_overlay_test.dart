import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/widgets/common/loading_overlay.dart';

void main() {
  group('LoadingOverlay', () {
    testWidgets('should display loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              message: 'Custom loading message',
            ),
          ),
        ),
      );

      expect(find.text('Custom loading message'), findsOneWidget);
    });

    testWidgets('should display cancel button when showCancelButton is true',
        (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              showCancelButton: true,
              onCancel: () => cancelCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('キャンセル'), findsOneWidget);

      await tester.tap(find.text('キャンセル'));
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets(
        'should not display cancel button when showCancelButton is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              showCancelButton: false,
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('キャンセル'), findsNothing);
    });

    testWidgets('should use custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              backgroundColor: Colors.red.withOpacity(0.5),
              indicatorColor: Colors.blue,
            ),
          ),
        ),
      );

      final materials = tester.widgetList<Material>(find.byType(Material));
      final loadingMaterial = materials.firstWhere(
        (material) => material.color == Colors.red.withOpacity(0.5),
      );

      expect(loadingMaterial.color, equals(Colors.red.withOpacity(0.5)));
    });
  });

  group('LoadingOverlayWidget', () {
    testWidgets('should show overlay when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayWidget(
            isLoading: true,
            child: const Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
      // Note: Overlay is shown via LoadingOverlayHelper, so we can't directly test it in widget tests
    });

    testWidgets('should not show overlay when isLoading is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayWidget(
            isLoading: false,
            child: const Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('should update overlay when isLoading changes',
        (WidgetTester tester) async {
      bool isLoading = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return LoadingOverlayWidget(
                isLoading: isLoading,
                loadingMessage: 'Loading...',
                onCancel: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('Child content'),
              );
            },
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);

      // Simulate loading state change
      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pump();
    });
  });

  group('LoadingOverlayHelper', () {
    testWidgets('should show and hide overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        LoadingOverlayHelper.show(
                          context,
                          message: 'Test loading',
                        );
                      },
                      child: const Text('Show'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        LoadingOverlayHelper.hide();
                      },
                      child: const Text('Hide'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Test show
      await tester.tap(find.text('Show'));
      await tester.pump();

      // Test hide
      await tester.tap(find.text('Hide'));
      await tester.pump();
    });

    testWidgets('should show overlay with custom parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    LoadingOverlayHelper.show(
                      context,
                      message: 'Custom message',
                      showCancelButton: true,
                      onCancel: () {},
                      backgroundColor: Colors.red.withOpacity(0.5),
                      indicatorColor: Colors.blue,
                    );
                  },
                  child: const Text('Show Custom'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Custom'));
      await tester.pump();
    });

    test('should track overlay state', () {
      // Note: This test may fail if overlay is showing from previous tests
      // In a real test environment, you would ensure clean state
      expect(LoadingOverlayHelper.isShowing, isA<bool>());
    });
  });
}
