import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/post.dart';
import '../models/srs_card.dart';
import '../models/review_log.dart';
import '../repositories/post_repository.dart';
import '../repositories/srs_repository.dart';

/// バックアップと復元を管理するサービス
class BackupService {
  final PostRepository _postRepository;
  final SrsRepository _srsRepository;

  BackupService({
    required PostRepository postRepository,
    required SrsRepository srsRepository,
  })  : _postRepository = postRepository,
        _srsRepository = srsRepository;

  /// バックアップデータの構造
  static const String _backupVersion = '1.0';
  static const String _backupAppName = 'snap_jp_learn_app';

  /// 全データをエクスポートしてJSONファイルとして保存
  Future<BackupResult> exportBackup() async {
    try {
      // データを収集
      final posts = await _postRepository.getAllPosts();
      final cards = await _srsRepository.getAllCards();
      final reviewLogs = await _srsRepository.getAllReviewLogs();

      // バックアップデータを構築
      final backupData = {
        'version': _backupVersion,
        'app': _backupAppName,
        'createdAt': DateTime.now().toIso8601String(),
        'data': {
          'posts': posts.map((post) => post.toJson()).toList(),
          'cards': cards.map((card) => card.toJson()).toList(),
          'reviewLogs': reviewLogs.map((log) => log.toJson()).toList(),
        },
        'metadata': {
          'postCount': posts.length,
          'cardCount': cards.length,
          'reviewLogCount': reviewLogs.length,
        },
      };

      // JSONに変換
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // ファイル名を生成（日付を含む）
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'snapjp_backup_$dateString.json';

      // 外部ストレージに保存
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw BackupException('外部ストレージにアクセスできません');
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return BackupResult.success(
        filePath: file.path,
        fileName: fileName,
        metadata: BackupMetadata(
          postCount: posts.length,
          cardCount: cards.length,
          reviewLogCount: reviewLogs.length,
          createdAt: now,
        ),
      );
    } catch (e) {
      return BackupResult.error('バックアップの作成に失敗しました: $e');
    }
  }

  /// JSONファイルからデータをインポートして復元
  Future<BackupResult> importBackup(String filePath) async {
    try {
      // ファイルを読み込み
      final file = File(filePath);
      if (!await file.exists()) {
        throw BackupException('ファイルが見つかりません: $filePath');
      }

      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        throw BackupException('ファイルが空です');
      }

      // JSONを解析
      final Map<String, dynamic> backupData;
      try {
        backupData = json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        throw BackupException('無効なJSONファイルです: $e');
      }

      // バージョンとアプリ名を確認
      if (backupData['app'] != _backupAppName) {
        throw BackupException('このアプリのバックアップファイルではありません');
      }

      // データを取得
      final data = backupData['data'] as Map<String, dynamic>;
      final postsData = data['posts'] as List<dynamic>;
      final cardsData = data['cards'] as List<dynamic>;
      final reviewLogsData = data['reviewLogs'] as List<dynamic>;

      // データを復元
      await _restoreData(postsData, cardsData, reviewLogsData);

      return BackupResult.success(
        filePath: filePath,
        fileName: file.path.split('/').last,
        metadata: BackupMetadata(
          postCount: postsData.length,
          cardCount: cardsData.length,
          reviewLogCount: reviewLogsData.length,
          createdAt: DateTime.tryParse(backupData['createdAt'] ?? '') ??
              DateTime.now(),
        ),
      );
    } catch (e) {
      return BackupResult.error('バックアップの復元に失敗しました: $e');
    }
  }

  /// データを復元する内部メソッド
  Future<void> _restoreData(
    List<dynamic> postsData,
    List<dynamic> cardsData,
    List<dynamic> reviewLogsData,
  ) async {
    try {
      // 既存データをクリア
      await _postRepository.clearAllPosts();
      await _srsRepository.clearAllData();

      // 投稿データを復元
      for (final postData in postsData) {
        try {
          final post = Post.fromJson(postData as Map<String, dynamic>);
          await _postRepository.importPosts([post.toJson()]);
        } catch (e) {
          // 個別の投稿でエラーが発生しても続行
          continue;
        }
      }

      // SRSカードを復元
      for (final cardData in cardsData) {
        try {
          final card = SrsCard.fromJson(cardData as Map<String, dynamic>);
          await _srsRepository.upsertCard(card);
        } catch (e) {
          // 個別のカードでエラーが発生しても続行
          continue;
        }
      }

      // レビューログを復元
      for (final logData in reviewLogsData) {
        try {
          final log = ReviewLog.fromJson(logData as Map<String, dynamic>);
          await _srsRepository.createReviewLog(log);
        } catch (e) {
          // 個別のログでエラーが発生しても続行
          continue;
        }
      }
    } catch (e) {
      throw BackupException('データの復元中にエラーが発生しました: $e');
    }
  }

  /// バックアップファイルの情報を取得（復元前の確認用）
  Future<BackupInfo> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw BackupException('ファイルが見つかりません: $filePath');
      }

      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        throw BackupException('ファイルが空です');
      }

      final Map<String, dynamic> backupData;
      try {
        backupData = json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        throw BackupException('無効なJSONファイルです: $e');
      }

      if (backupData['app'] != _backupAppName) {
        throw BackupException('このアプリのバックアップファイルではありません');
      }

      final metadata = backupData['metadata'] as Map<String, dynamic>;
      final createdAt =
          DateTime.tryParse(backupData['createdAt'] ?? '') ?? DateTime.now();

      return BackupInfo(
        fileName: file.path.split('/').last,
        version: backupData['version'] ?? '不明',
        createdAt: createdAt,
        postCount: metadata['postCount'] ?? 0,
        cardCount: metadata['cardCount'] ?? 0,
        reviewLogCount: metadata['reviewLogCount'] ?? 0,
        fileSize: await file.length(),
      );
    } catch (e) {
      throw BackupException('バックアップファイルの情報取得に失敗しました: $e');
    }
  }
}

/// バックアップ結果
class BackupResult {
  final bool isSuccess;
  final String? message;
  final String? filePath;
  final String? fileName;
  final BackupMetadata? metadata;

  const BackupResult._({
    required this.isSuccess,
    this.message,
    this.filePath,
    this.fileName,
    this.metadata,
  });

  factory BackupResult.success({
    required String filePath,
    required String fileName,
    required BackupMetadata metadata,
  }) {
    return BackupResult._(
      isSuccess: true,
      filePath: filePath,
      fileName: fileName,
      metadata: metadata,
    );
  }

  factory BackupResult.error(String message) {
    return BackupResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// バックアップメタデータ
class BackupMetadata {
  final int postCount;
  final int cardCount;
  final int reviewLogCount;
  final DateTime createdAt;

  const BackupMetadata({
    required this.postCount,
    required this.cardCount,
    required this.reviewLogCount,
    required this.createdAt,
  });
}

/// バックアップファイル情報
class BackupInfo {
  final String fileName;
  final String version;
  final DateTime createdAt;
  final int postCount;
  final int cardCount;
  final int reviewLogCount;
  final int fileSize;

  const BackupInfo({
    required this.fileName,
    required this.version,
    required this.createdAt,
    required this.postCount,
    required this.cardCount,
    required this.reviewLogCount,
    required this.fileSize,
  });
}

/// バックアップ関連の例外
class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}
