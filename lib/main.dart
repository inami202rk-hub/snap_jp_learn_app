import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'models/post.dart';
import 'models/srs_card.dart';
import 'models/review_log.dart';
import 'services/usage_tracker.dart';
import 'services/error_log_service.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      // Sentry DSN（本番環境では環境変数から取得）
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '', // 開発時は空文字列
      );

      // デバッグモードでは詳細ログを有効化
      options.debug = kDebugMode;

      // パフォーマンス監視を有効化
      options.tracesSampleRate = 0.1;

      // リリース情報を設定
      options.release = 'snap-jp-learn-app@1.0.0';

      // 環境情報を設定
      options.environment = kDebugMode ? 'development' : 'production';
    },
    appRunner: () => _runApp(),
  );
}

Future<void> _runApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // エラーハンドリングを設定
    _setupErrorHandling();

    // Hive初期化
    await Hive.initFlutter();

    // 型アダプターを登録
    Hive.registerAdapter(PostAdapter());
    Hive.registerAdapter(SrsCardAdapter());
    Hive.registerAdapter(ReviewLogAdapter());
    Hive.registerAdapter(UsageEventAdapter());

    // エラーログサービスを初期化
    await ErrorLogService.instance.initialize();

    // アプリを起動
    runApp(const SnapJpLearnApp());
  } catch (e, stackTrace) {
    // 初期化エラーをSentryに送信
    await Sentry.captureException(e, stackTrace: stackTrace);

    // エラーログサービスが利用可能な場合は記録
    try {
      await ErrorLogService.instance.logError(
        type: ErrorLogType.crash,
        message: 'App initialization failed: $e',
        stackTrace: stackTrace.toString(),
        context: {'phase': 'initialization'},
      );
    } catch (_) {
      // エラーログサービスも失敗した場合は無視
    }

    // アプリを起動（エラーがあっても起動を試行）
    runApp(const SnapJpLearnApp());
  }
}

/// エラーハンドリングを設定
void _setupErrorHandling() {
  // Flutterフレームワークエラーをキャッチ
  FlutterError.onError = (FlutterErrorDetails details) async {
    // Sentryに送信
    await Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );

    // エラーログサービスに記録
    await ErrorLogService.instance.logError(
      type: ErrorLogType.exception,
      message: 'Flutter framework error: ${details.exception}',
      stackTrace: details.stack?.toString(),
      context: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    // デバッグモードでは詳細ログを出力
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // プラットフォームエラーをキャッチ
  PlatformDispatcher.instance.onError = (error, stack) {
    // Sentryに送信（非同期処理は別途実行）
    Sentry.captureException(error, stackTrace: stack);

    // エラーログサービスに記録（非同期処理は別途実行）
    ErrorLogService.instance.logError(
      type: ErrorLogType.crash,
      message: 'Platform error: $error',
      stackTrace: stack.toString(),
      context: {'source': 'platform'},
    );

    return true; // エラーを処理済みとしてマーク
  };
}
