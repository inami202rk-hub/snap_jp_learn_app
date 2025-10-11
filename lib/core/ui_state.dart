/// アプリ全体で統一されたUI状態を表すsealed class
///
/// 読み込み中、成功、エラーの3つの状態を表現し、
/// 各画面で一貫したUXを提供します。
sealed class UiState<T> {
  const UiState();

  /// 現在の状態が読み込み中かどうか
  bool get isLoading => this is UiLoading<T>;

  /// 現在の状態が成功かどうか
  bool get isSuccess => this is UiSuccess<T>;

  /// 現在の状態がエラーかどうか
  bool get isError => this is UiError<T>;

  /// 成功時のデータを取得（null safety対応）
  T? get data => switch (this) {
        UiSuccess<T>(data: final data) => data,
        _ => null,
      };

  /// エラー時のメッセージを取得（null safety対応）
  String? get errorMessage => switch (this) {
        UiError<T>(message: final message) => message,
        _ => null,
      };

  /// 状態に応じた処理を実行
  ///
  /// Example:
  /// ```dart
  /// uiState.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   success: (data) => Text('Data: $data'),
  ///   error: (message) => Text('Error: $message'),
  /// );
  /// ```
  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (this) {
      UiLoading<T>() => loading(),
      UiSuccess<T>(data: final data) => success(data),
      UiError<T>(message: final message) => error(message),
    };
  }

  /// 状態に応じた処理を実行（部分的な場合）
  ///
  /// Example:
  /// ```dart
  /// uiState.maybeWhen(
  ///   loading: () => CircularProgressIndicator(),
  ///   orElse: () => SizedBox.shrink(),
  /// );
  /// ```
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      UiLoading<T>() => loading?.call() ?? orElse(),
      UiSuccess<T>(data: final data) => success?.call(data) ?? orElse(),
      UiError<T>(message: final message) => error?.call(message) ?? orElse(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return switch (this) {
      UiLoading<T>() => other is UiLoading<T>,
      UiSuccess<T>(data: final data) =>
        other is UiSuccess<T> && other.data == data,
      UiError<T>(message: final message) =>
        other is UiError<T> && other.message == message,
    };
  }

  @override
  int get hashCode {
    return switch (this) {
      UiLoading<T>() => Object.hash(UiLoading<T>, T),
      UiSuccess<T>(data: final data) => Object.hash(UiSuccess<T>, data),
      UiError<T>(message: final message) => Object.hash(UiError<T>, message),
    };
  }

  @override
  String toString() {
    return switch (this) {
      UiLoading<T>() => 'UiLoading<$T>()',
      UiSuccess<T>(data: final data) => 'UiSuccess<$T>($data)',
      UiError<T>(message: final message) => 'UiError<$T>($message)',
    };
  }
}

/// 読み込み中状態
class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

/// 成功状態（データ付き）
class UiSuccess<T> extends UiState<T> {
  final T data;

  const UiSuccess(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UiSuccess<T> && other.data == data;
  }

  @override
  int get hashCode => Object.hash(UiSuccess<T>, data);
}

/// エラー状態（メッセージ付き）
class UiError<T> extends UiState<T> {
  final String message;

  const UiError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UiError<T> && other.message == message;
  }

  @override
  int get hashCode => Object.hash(UiError<T>, message);
}

/// UiState用のユーティリティ関数
class UiStateUtils {
  UiStateUtils._();

  /// 初期状態（読み込み中）
  static UiState<T> loading<T>() => UiLoading<T>();

  /// 成功状態
  static UiState<T> success<T>(T data) => UiSuccess(data);

  /// エラー状態
  static UiState<T> error<T>(String message) => UiError(message);

  /// ネットワークエラーの場合のメッセージ
  static const String networkErrorMessage = 'ネットワークに接続されていません';

  /// サーバーエラーの場合のメッセージ
  static const String serverErrorMessage = 'サーバーでエラーが発生しました';

  /// OCR処理エラーの場合のメッセージ
  static const String ocrErrorMessage = '画像の読み取りに失敗しました';

  /// 同期エラーの場合のメッセージ
  static const String syncErrorMessage = '同期に失敗しました';
}
