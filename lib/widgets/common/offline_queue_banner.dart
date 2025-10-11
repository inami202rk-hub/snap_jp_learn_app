import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offline_queue_service.dart';
import '../../generated/app_localizations.dart';

/// オフラインキュー状態を表示するバナー
class OfflineQueueBanner extends StatelessWidget {
  const OfflineQueueBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineQueueService>(
      builder: (context, queueService, child) {
        final taskCount = queueService.taskCount;
        final status = queueService.status;

        // タスクがない場合は何も表示しない
        if (taskCount == 0) return const SizedBox.shrink();

        // 処理中の場合
        if (status == OfflineQueueStatus.processing) {
          return _buildProcessingBanner(context);
        }

        // エラーの場合
        if (status == OfflineQueueStatus.error) {
          return _buildErrorBanner(context, queueService.lastError);
        }

        // 完了の場合（一時的に表示）
        if (status == OfflineQueueStatus.completed) {
          return _buildCompletedBanner(context, taskCount);
        }

        // オフライン中の場合
        return _buildOfflineBanner(context, taskCount);
      },
    );
  }

  /// 処理中バナー
  Widget _buildProcessingBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.syncingOfflineTasks,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// エラーバナー
  Widget _buildErrorBanner(BuildContext context, String? error) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineSyncFailed,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 完了バナー（一時的表示）
  Widget _buildCompletedBanner(BuildContext context, int taskCount) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineSyncCompleted(taskCount),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// オフラインバナー
  Widget _buildOfflineBanner(BuildContext context, int taskCount) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineTasksQueued(taskCount),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// オフラインキューバナーを統合したオフラインノーティス
class OfflineNoticeWithQueue extends StatelessWidget {
  final Widget child;
  final String? offlineMessage;
  final String? onlineMessage;
  final Duration? onlineMessageDuration;

  const OfflineNoticeWithQueue({
    super.key,
    required this.child,
    this.offlineMessage,
    this.onlineMessage,
    this.onlineMessageDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // オフラインキュー状態バナー（最上部）
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: OfflineQueueBanner(),
        ),
      ],
    );
  }
}
