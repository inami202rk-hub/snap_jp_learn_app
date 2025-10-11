import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../../generated/app_localizations.dart';

/// ネットワーク接続状態を監視し、オフライン時に通知を表示するウィジェット
class OfflineNotice extends StatelessWidget {
  final Widget child;
  final String? offlineMessage;
  final String? onlineMessage;
  final Duration? onlineMessageDuration;
  final IconData? offlineIcon;
  final IconData? onlineIcon;
  final Color? offlineBackgroundColor;
  final Color? onlineBackgroundColor;
  final Color? offlineTextColor;
  final Color? onlineTextColor;

  const OfflineNotice({
    super.key,
    required this.child,
    this.offlineMessage,
    this.onlineMessage,
    this.onlineMessageDuration,
    this.offlineIcon,
    this.onlineIcon,
    this.offlineBackgroundColor,
    this.onlineBackgroundColor,
    this.offlineTextColor,
    this.onlineTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConnectivityNotifier(),
      child: _OfflineNoticeContent(
        offlineMessage: offlineMessage,
        onlineMessage: onlineMessage,
        onlineMessageDuration: onlineMessageDuration,
        offlineIcon: offlineIcon,
        onlineIcon: onlineIcon,
        offlineBackgroundColor: offlineBackgroundColor,
        onlineBackgroundColor: onlineBackgroundColor,
        offlineTextColor: offlineTextColor,
        onlineTextColor: onlineTextColor,
        child: child,
      ),
    );
  }
}

class _OfflineNoticeContent extends StatelessWidget {
  final Widget child;
  final String? offlineMessage;
  final String? onlineMessage;
  final Duration? onlineMessageDuration;
  final IconData? offlineIcon;
  final IconData? onlineIcon;
  final Color? offlineBackgroundColor;
  final Color? onlineBackgroundColor;
  final Color? offlineTextColor;
  final Color? onlineTextColor;

  const _OfflineNoticeContent({
    required this.child,
    this.offlineMessage,
    this.onlineMessage,
    this.onlineMessageDuration,
    this.offlineIcon,
    this.onlineIcon,
    this.offlineBackgroundColor,
    this.onlineBackgroundColor,
    this.offlineTextColor,
    this.onlineTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
      builder: (context, connectivityNotifier, _) {
        final isOnline = connectivityNotifier.isOnline;
        final showOnlineMessage = connectivityNotifier.shouldShowOnlineMessage;

        return Stack(
          children: [
            child,
            if (!isOnline || showOnlineMessage)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _NetworkStatusBanner(
                  isOnline: isOnline,
                  message: isOnline
                      ? (onlineMessage ??
                          (AppLocalizations.of(context)?.online ??
                              'インターネットに接続されました'))
                      : (offlineMessage ??
                          (AppLocalizations.of(context)?.offline ?? 'オフラインです')),
                  icon: isOnline ? onlineIcon : offlineIcon,
                  backgroundColor:
                      isOnline ? onlineBackgroundColor : offlineBackgroundColor,
                  textColor: isOnline ? onlineTextColor : offlineTextColor,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ネットワーク接続状態を管理するNotifier
class ConnectivityNotifier extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;
  bool _shouldShowOnlineMessage = false;
  Timer? _onlineMessageTimer;

  bool get isOnline => _isOnline;
  bool get shouldShowOnlineMessage => _shouldShowOnlineMessage;

  ConnectivityNotifier() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // 初期状態を取得
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivity(connectivityResult);

    // 接続状態の変化を監視
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (wasOnline != _isOnline) {
      notifyListeners();

      // オフラインからオンラインに変わった場合、オンラインメッセージを表示
      if (!wasOnline && _isOnline) {
        _showOnlineMessage();
      } else if (wasOnline && !_isOnline) {
        _hideOnlineMessage();
      }
    }
  }

  void _showOnlineMessage() {
    _shouldShowOnlineMessage = true;
    notifyListeners();

    // タイマーをクリア
    _onlineMessageTimer?.cancel();

    // 一定時間後にメッセージを非表示
    _onlineMessageTimer = Timer(const Duration(seconds: 3), () {
      _hideOnlineMessage();
    });
  }

  void _hideOnlineMessage() {
    _shouldShowOnlineMessage = false;
    _onlineMessageTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _onlineMessageTimer?.cancel();
    super.dispose();
  }
}

/// ネットワーク状態バナー
class _NetworkStatusBanner extends StatelessWidget {
  final bool isOnline;
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const _NetworkStatusBanner({
    required this.isOnline,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: backgroundColor ?? (isOnline ? Colors.green : Colors.orange),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              icon ?? (isOnline ? Icons.wifi : Icons.wifi_off),
              color: textColor ?? Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 簡易版オフライン通知（Provider不要）
class SimpleOfflineNotice extends StatefulWidget {
  final Widget child;
  final String? offlineMessage;
  final IconData? offlineIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const SimpleOfflineNotice({
    super.key,
    required this.child,
    this.offlineMessage,
    this.offlineIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<SimpleOfflineNotice> createState() => _SimpleOfflineNoticeState();
}

class _SimpleOfflineNoticeState extends State<SimpleOfflineNotice> {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    // 初期状態を取得
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivity(connectivityResult);

    // 接続状態の変化を監視
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(ConnectivityResult result) {
    final isOnline = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (mounted && _isOnline != isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _NetworkStatusBanner(
              isOnline: false,
              message: widget.offlineMessage ??
                  (AppLocalizations.of(context)?.offline ?? 'オフラインです'),
              icon: widget.offlineIcon,
              backgroundColor: widget.backgroundColor,
              textColor: widget.textColor,
            ),
          ),
      ],
    );
  }
}
