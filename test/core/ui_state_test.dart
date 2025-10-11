import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/core/ui_state.dart';

void main() {
  group('UiState', () {
    group('UiLoading', () {
      test('should have correct properties', () {
        const loading = UiLoading<String>();

        expect(loading.isLoading, isTrue);
        expect(loading.isSuccess, isFalse);
        expect(loading.isError, isFalse);
        expect(loading.data, isNull);
        expect(loading.errorMessage, isNull);
      });

      test('should be equal to other UiLoading instances', () {
        const loading1 = UiLoading<String>();
        const loading2 = UiLoading<String>();

        expect(loading1, equals(loading2));
        expect(loading1.hashCode, equals(loading2.hashCode));
      });

      test('should have correct string representation', () {
        const loading = UiLoading<String>();

        expect(loading.toString(), equals('UiLoading<String>()'));
      });
    });

    group('UiSuccess', () {
      test('should have correct properties', () {
        const success = UiSuccess<String>('test data');

        expect(success.isLoading, isFalse);
        expect(success.isSuccess, isTrue);
        expect(success.isError, isFalse);
        expect(success.data, equals('test data'));
        expect(success.errorMessage, isNull);
      });

      test('should be equal to other UiSuccess instances with same data', () {
        const success1 = UiSuccess<String>('test data');
        const success2 = UiSuccess<String>('test data');

        expect(success1, equals(success2));
        expect(success1.hashCode, equals(success2.hashCode));
      });

      test('should not be equal to UiSuccess instances with different data',
          () {
        const success1 = UiSuccess<String>('test data');
        const success2 = UiSuccess<String>('different data');

        expect(success1, isNot(equals(success2)));
      });

      test('should have correct string representation', () {
        const success = UiSuccess<String>('test data');

        expect(success.toString(), equals('UiSuccess<String>(test data)'));
      });
    });

    group('UiError', () {
      test('should have correct properties', () {
        const error = UiError<String>('error message');

        expect(error.isLoading, isFalse);
        expect(error.isSuccess, isFalse);
        expect(error.isError, isTrue);
        expect(error.data, isNull);
        expect(error.errorMessage, equals('error message'));
      });

      test('should be equal to other UiError instances with same message', () {
        const error1 = UiError<String>('error message');
        const error2 = UiError<String>('error message');

        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('should not be equal to UiError instances with different messages',
          () {
        const error1 = UiError<String>('error message');
        const error2 = UiError<String>('different message');

        expect(error1, isNot(equals(error2)));
      });

      test('should have correct string representation', () {
        const error = UiError<String>('error message');

        expect(error.toString(), equals('UiError<String>(error message)'));
      });
    });

    group('when method', () {
      test('should call correct function for UiLoading', () {
        const loading = UiLoading<String>();

        final result = loading.when(
          loading: () => 'loading',
          success: (data) => 'success: $data',
          error: (message) => 'error: $message',
        );

        expect(result, equals('loading'));
      });

      test('should call correct function for UiSuccess', () {
        const success = UiSuccess<String>('test data');

        final result = success.when(
          loading: () => 'loading',
          success: (data) => 'success: $data',
          error: (message) => 'error: $message',
        );

        expect(result, equals('success: test data'));
      });

      test('should call correct function for UiError', () {
        const error = UiError<String>('error message');

        final result = error.when(
          loading: () => 'loading',
          success: (data) => 'success: $data',
          error: (message) => 'error: $message',
        );

        expect(result, equals('error: error message'));
      });
    });

    group('maybeWhen method', () {
      test('should call provided function for UiLoading', () {
        const loading = UiLoading<String>();

        final result = loading.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'default',
        );

        expect(result, equals('loading'));
      });

      test('should call orElse for UiSuccess when no success handler provided',
          () {
        const success = UiSuccess<String>('test data');

        final result = success.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'default',
        );

        expect(result, equals('default'));
      });

      test('should call orElse for UiError when no error handler provided', () {
        const error = UiError<String>('error message');

        final result = error.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'default',
        );

        expect(result, equals('default'));
      });
    });
  });

  group('UiStateUtils', () {
    test('should create loading state', () {
      final loading = UiStateUtils.loading<String>();

      expect(loading, isA<UiLoading<String>>());
    });

    test('should create success state', () {
      final success = UiStateUtils.success<String>('test data');

      expect(success, isA<UiSuccess<String>>());
      expect(success.data, equals('test data'));
    });

    test('should create error state', () {
      final error = UiStateUtils.error<String>('error message');

      expect(error, isA<UiError<String>>());
      expect(error.errorMessage, equals('error message'));
    });

    test('should have correct error message constants', () {
      expect(UiStateUtils.networkErrorMessage, equals('ネットワークに接続されていません'));
      expect(UiStateUtils.serverErrorMessage, equals('サーバーでエラーが発生しました'));
      expect(UiStateUtils.ocrErrorMessage, equals('画像の読み取りに失敗しました'));
      expect(UiStateUtils.syncErrorMessage, equals('同期に失敗しました'));
    });
  });
}
