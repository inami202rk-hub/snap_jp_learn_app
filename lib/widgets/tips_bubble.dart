import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tips_service.dart';
import '../generated/app_localizations.dart';

/// Tipsバブルウィジェット
class TipsBubble extends StatefulWidget {
  final String tipId;
  final Widget child;
  final String? customMessage;
  final Duration? displayDuration;
  final TipsPosition position;
  final VoidCallback? onTap;
  final bool showCloseButton;

  const TipsBubble({
    super.key,
    required this.tipId,
    required this.child,
    this.customMessage,
    this.displayDuration,
    this.position = TipsPosition.top,
    this.onTap,
    this.showCloseButton = true,
  });

  @override
  State<TipsBubble> createState() => _TipsBubbleState();
}

class _TipsBubbleState extends State<TipsBubble>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 初期化後にTips表示をチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTip();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  /// Tips表示をチェックして表示
  Future<void> _checkAndShowTip() async {
    final tipsService = Provider.of<TipsService>(context, listen: false);

    if (await tipsService.canShowTip(widget.tipId)) {
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();

      // 自動非表示タイマーを設定
      final duration = widget.displayDuration ?? const Duration(seconds: 5);
      _autoHideTimer = Timer(duration, () {
        _hideTip();
      });

      // Tips表示済みとしてマーク
      await tipsService.markTipAsShown(widget.tipId);
    }
  }

  /// Tipsを非表示にする
  void _hideTip() {
    if (!mounted) return;

    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  /// Tipsをタップした時の処理
  void _onTipTap() {
    widget.onTap?.call();
    _hideTip();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            top: widget.position == TipsPosition.top ? -10 : null,
            bottom: widget.position == TipsPosition.bottom ? -10 : null,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTipBubble(),
            ),
          ),
      ],
    );
  }

  /// Tipsバブルを構築
  Widget _buildTipBubble() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _onTipTap,
              child: Text(
                _getTipMessage(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (widget.showCloseButton)
            GestureDetector(
              onTap: _hideTip,
              child: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  /// Tipsメッセージを取得
  String _getTipMessage() {
    if (widget.customMessage != null) {
      return widget.customMessage!;
    }

    final l10n = AppLocalizations.of(context)!;

    switch (widget.tipId) {
      case TipsId.ocrLighting:
        return l10n.tipsOcrLighting;
      case TipsId.ocrAngle:
        return l10n.tipsOcrAngle;
      case TipsId.syncAuto:
        return l10n.tipsSyncAuto;
      case TipsId.cardReview:
        return l10n.tipsCardReview;
      case TipsId.offlineMode:
        return l10n.tipsOfflineMode;
      default:
        return '💡 Tip: ${widget.tipId}';
    }
  }
}

/// Tips表示位置
enum TipsPosition {
  top,
  bottom,
}

/// Tipsバブルヘルパー
class TipsBubbleHelper {
  /// 指定されたウィジェットをTipsバブルでラップ
  static Widget wrap({
    required String tipId,
    required Widget child,
    String? customMessage,
    Duration? displayDuration,
    TipsPosition position = TipsPosition.top,
    VoidCallback? onTap,
    bool showCloseButton = true,
  }) {
    return TipsBubble(
      tipId: tipId,
      customMessage: customMessage,
      displayDuration: displayDuration,
      position: position,
      onTap: onTap,
      showCloseButton: showCloseButton,
      child: child,
    );
  }
}

/// 条件付きTipsバブル
class ConditionalTipsBubble extends StatelessWidget {
  final String tipId;
  final Widget child;
  final String? customMessage;
  final Duration? displayDuration;
  final TipsPosition position;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final bool Function()? condition;

  const ConditionalTipsBubble({
    super.key,
    required this.tipId,
    required this.child,
    this.customMessage,
    this.displayDuration,
    this.position = TipsPosition.top,
    this.onTap,
    this.showCloseButton = true,
    this.condition,
  });

  @override
  Widget build(BuildContext context) {
    // 条件が指定されている場合はチェック
    if (condition != null && !condition!()) {
      return child;
    }

    return TipsBubble(
      tipId: tipId,
      customMessage: customMessage,
      displayDuration: displayDuration,
      position: position,
      onTap: onTap,
      showCloseButton: showCloseButton,
      child: child,
    );
  }
}
