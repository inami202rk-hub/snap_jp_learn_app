import 'package:flutter/material.dart';

/// アプリ全体で統一されたローディングオーバーレイ
/// 
/// 半透明背景にローディングインジケータとキャンセルボタンを表示します。
/// OverlayEntryを使用して最上層に表示され、ユーザーの操作をブロックします。
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool showCancelButton;
  final VoidCallback? onCancel;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    this.message,
    this.showCancelButton = false,
    this.onCancel,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: indicatorColor ?? colorScheme.primary,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showCancelButton && onCancel != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// LoadingOverlayを表示・非表示するためのヘルパークラス
class LoadingOverlayHelper {
  static OverlayEntry? _currentOverlay;

  /// ローディングオーバーレイを表示
  /// 
  /// [context] - 表示するコンテキスト
  /// [message] - 表示するメッセージ（オプション）
  /// [showCancelButton] - キャンセルボタンを表示するかどうか
  /// [onCancel] - キャンセル時のコールバック
  /// [backgroundColor] - 背景色（オプション）
  /// [indicatorColor] - インジケータ色（オプション）
  static void show(
    BuildContext context, {
    String? message,
    bool showCancelButton = false,
    VoidCallback? onCancel,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    // 既存のオーバーレイがあれば非表示にする
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => LoadingOverlay(
        message: message,
        showCancelButton: showCancelButton,
        onCancel: () {
          hide();
          onCancel?.call();
        },
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// ローディングオーバーレイを非表示
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// 現在オーバーレイが表示されているかどうか
  static bool get isShowing => _currentOverlay != null;
}

/// LoadingOverlayを簡単に使用するためのStatefulWidget
class LoadingOverlayWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const LoadingOverlayWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.showCancelButton = false,
    this.onCancel,
  });

  @override
  State<LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<LoadingOverlayWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      _showOverlay();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !oldWidget.isLoading) {
      _showOverlay();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _hideOverlay();
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isLoading) {
        LoadingOverlayHelper.show(
          context,
          message: widget.loadingMessage,
          showCancelButton: widget.showCancelButton,
          onCancel: widget.onCancel,
        );
      }
    });
  }

  void _hideOverlay() {
    LoadingOverlayHelper.hide();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
