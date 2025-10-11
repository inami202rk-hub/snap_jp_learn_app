import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../services/onboarding_service.dart';

/// Tips表示用のウィジェット
class TipsWidget extends StatefulWidget {
  final String tipKey;
  final String title;
  final String description;
  final Widget child;
  final GlobalKey globalKey;

  const TipsWidget({
    super.key,
    required this.tipKey,
    required this.title,
    required this.description,
    required this.child,
    required this.globalKey,
  });

  @override
  State<TipsWidget> createState() => _TipsWidgetState();
}

class _TipsWidgetState extends State<TipsWidget> {
  bool _showTip = false;

  @override
  void initState() {
    super.initState();
    _checkTipStatus();
  }

  Future<void> _checkTipStatus() async {
    final isShown = await OnboardingService.isTipShown(widget.tipKey);
    if (!isShown && mounted) {
      // 少し遅延してからTipsを表示（UIの描画完了を待つ）
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showTip = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTip) {
      return widget.child;
    }

    return Showcase(
      key: widget.globalKey,
      title: widget.title,
      description: widget.description,
      targetShapeBorder: const CircleBorder(),
      tooltipBackgroundColor: Theme.of(context).colorScheme.surface,
      textColor: Theme.of(context).colorScheme.onSurface,
      onTargetClick: _dismissTip,
      onBarrierClick: _dismissTip,
      disposeOnTap: true,
      child: widget.child,
    );
  }

  void _dismissTip() async {
    await OnboardingService.markTipShown(widget.tipKey);
    if (mounted) {
      setState(() {
        _showTip = false;
      });
    }
  }
}

/// Tips表示のヘルパークラス
class TipsHelper {
  static final Map<String, GlobalKey> _globalKeys = {};

  static GlobalKey getGlobalKey(String tipKey) {
    if (!_globalKeys.containsKey(tipKey)) {
      _globalKeys[tipKey] = GlobalKey();
    }
    return _globalKeys[tipKey]!;
  }

  /// 特定のTipsを手動で表示
  static void showTip(BuildContext context, String tipKey) {
    final globalKey = getGlobalKey(tipKey);
    ShowCaseWidget.of(context).startShowCase([globalKey]);
  }

  /// 全てのTipsをリセット（デバッグ用）
  static Future<void> resetAllTips() async {
    await OnboardingService.resetAllTips();
  }
}
