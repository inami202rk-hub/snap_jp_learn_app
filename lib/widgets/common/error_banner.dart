import 'package:flutter/material.dart';
import '../../core/ui_state.dart';
import '../../generated/app_localizations.dart';

/// アプリ全体で統一されたエラーバナー
///
/// MaterialBanner風のデザインで、エラーメッセージと再試行ボタンを表示します。
/// 画面の上部に固定表示され、ユーザーにエラー状況を通知します。
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryButtonText;
  final String? dismissButtonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration? autoHideDuration;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText,
    this.dismissButtonText,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.autoHideDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: backgroundColor ?? colorScheme.error,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: textColor ?? colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor ?? colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: textColor ?? colorScheme.onError,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  retryButtonText ??
                      (AppLocalizations.of(context)?.retry ?? '再試行'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: textColor ?? colorScheme.onError,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ErrorBannerを表示・非表示するためのヘルパークラス
class ErrorBannerHelper {
  static OverlayEntry? _currentBanner;

  /// エラーバナーを表示
  ///
  /// [context] - 表示するコンテキスト
  /// [message] - エラーメッセージ
  /// [onRetry] - 再試行時のコールバック
  /// [onDismiss] - 非表示時のコールバック
  /// [retryButtonText] - 再試行ボタンのテキスト
  /// [dismissButtonText] - 非表示ボタンのテキスト
  /// [icon] - アイコン
  /// [backgroundColor] - 背景色
  /// [textColor] - テキスト色
  /// [autoHideDuration] - 自動非表示時間（nullの場合は非表示しない）
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryButtonText,
    String? dismissButtonText,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration? autoHideDuration,
  }) {
    // 既存のバナーがあれば非表示にする
    hide();

    _currentBanner = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ErrorBanner(
          message: message,
          onRetry: onRetry,
          onDismiss: () {
            hide();
            onDismiss?.call();
          },
          retryButtonText: retryButtonText,
          dismissButtonText: dismissButtonText,
          icon: icon,
          backgroundColor: backgroundColor,
          textColor: textColor,
          autoHideDuration: autoHideDuration,
        ),
      ),
    );

    Overlay.of(context).insert(_currentBanner!);

    // 自動非表示の設定
    if (autoHideDuration != null) {
      Future.delayed(autoHideDuration, () {
        hide();
      });
    }
  }

  /// エラーバナーを非表示
  static void hide() {
    _currentBanner?.remove();
    _currentBanner = null;
  }

  /// 現在バナーが表示されているかどうか
  static bool get isShowing => _currentBanner != null;
}

/// ErrorBannerを簡単に使用するためのStatefulWidget
class ErrorBannerWidget extends StatefulWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryButtonText;
  final String? dismissButtonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration? autoHideDuration;

  const ErrorBannerWidget({
    super.key,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText,
    this.dismissButtonText,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.autoHideDuration,
  });

  @override
  State<ErrorBannerWidget> createState() => _ErrorBannerWidgetState();
}

class _ErrorBannerWidgetState extends State<ErrorBannerWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      _showBanner();
    }
  }

  @override
  void didUpdateWidget(ErrorBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.errorMessage != null &&
        widget.errorMessage != oldWidget.errorMessage) {
      _showBanner();
    } else if (widget.errorMessage == null && oldWidget.errorMessage != null) {
      _hideBanner();
    }
  }

  @override
  void dispose() {
    _hideBanner();
    super.dispose();
  }

  void _showBanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.errorMessage != null) {
        ErrorBannerHelper.show(
          context,
          message: widget.errorMessage!,
          onRetry: widget.onRetry,
          onDismiss: widget.onDismiss,
          retryButtonText: widget.retryButtonText,
          dismissButtonText: widget.dismissButtonText,
          icon: widget.icon,
          backgroundColor: widget.backgroundColor,
          textColor: widget.textColor,
          autoHideDuration: widget.autoHideDuration,
        );
      }
    });
  }

  void _hideBanner() {
    ErrorBannerHelper.hide();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// UiStateに対応したエラーバナー
class UiStateErrorBanner<T> extends StatelessWidget {
  final Widget child;
  final UiState<T> uiState;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String Function(String)? messageFormatter;
  final Duration? autoHideDuration;

  const UiStateErrorBanner({
    super.key,
    required this.child,
    required this.uiState,
    this.onRetry,
    this.onDismiss,
    this.messageFormatter,
    this.autoHideDuration,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBannerWidget(
      errorMessage: uiState.isError
          ? (messageFormatter?.call(uiState.errorMessage!) ??
              uiState.errorMessage)
          : null,
      onRetry: onRetry,
      onDismiss: onDismiss,
      autoHideDuration: autoHideDuration,
      child: child,
    );
  }
}
