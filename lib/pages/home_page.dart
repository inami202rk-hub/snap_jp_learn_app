import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../features/settings/services/settings_service.dart';
import '../widgets/srs_preview_card.dart';
import '../services/ocr_service.dart';
import '../services/ocr_service_mlkit.dart';
import '../services/camera_permission_service.dart';
import '../services/text_normalizer.dart';

class HomePage extends StatefulWidget {
  final OcrService? ocrService; // テスト用にDI可能

  const HomePage({super.key, this.ocrService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final OcrService _ocrService;
  final CameraPermissionService _permissionService = CameraPermissionService();

  @override
  void initState() {
    super.initState();
    // テスト用にDIされたサービスがあればそれを使用、なければML Kit実装を使用
    _ocrService = widget.ocrService ?? OcrServiceMlkit();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// OCRテスト用メソッド（後方互換性のため）
  Future<void> _testOcr(BuildContext context) async {
    try {
      // ローディング表示
      _showLoadingDialog(context, 'OCR処理中...');

      // OCR処理実行（モック）
      final extractedText = await _ocrService.extractTextFromImage();

      // ローディング終了
      if (!mounted) return;
      Navigator.of(context).pop();

      // 結果をダイアログで表示
      _showOcrResultDialog(context, extractedText);
    } catch (e) {
      // エラー処理
      if (!mounted) return;
      _handleOcrError(context, e);
    }
  }

  /// カメラ撮影からOCR処理までのフロー
  Future<void> _captureAndOcr(BuildContext context) async {
    try {
      // カメラ権限を確認
      final permissionResult = await _permissionService
          .ensureCameraPermission();

      if (permissionResult != CameraPermissionResult.granted) {
        _handlePermissionError(context, permissionResult);
        return;
      }

      // ローディング表示
      _showLoadingDialog(context, '撮影準備中...');

      // カメラで撮影してOCR処理
      final extractedText = await _ocrService.extractTextFromImage(
        source: ImageSource.camera,
      );

      // ローディング終了
      if (!mounted) return;
      Navigator.of(context).pop();

      // 結果をダイアログで表示
      _showOcrResultDialog(context, extractedText);
    } catch (e) {
      // エラー処理
      if (!mounted) return;
      _handleOcrError(context, e);
    }
  }

  /// ギャラリーから画像選択してOCR処理
  Future<void> _selectFromGalleryAndOcr(BuildContext context) async {
    try {
      // ローディング表示
      _showLoadingDialog(context, '画像選択中...');

      // ギャラリーから選択してOCR処理
      final extractedText = await _ocrService.extractTextFromImage(
        source: ImageSource.gallery,
      );

      // ローディング終了
      if (!mounted) return;
      Navigator.of(context).pop();

      // 結果をダイアログで表示
      _showOcrResultDialog(context, extractedText);
    } catch (e) {
      // エラー処理
      if (!mounted) return;
      _handleOcrError(context, e);
    }
  }

  /// ローディングダイアログを表示
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// OCRエラーを処理
  void _handleOcrError(BuildContext context, dynamic error) {
    if (!mounted) return;

    // ローディングダイアログが表示されている場合は閉じる
    try {
      Navigator.of(context).pop();
    } catch (e) {
      // ダイアログが既に閉じられている場合は無視
    }

    String errorMessage = 'OCRエラーが発生しました';
    bool shouldShowError = true;

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('キャンセル') || errorString.contains('cancel')) {
      shouldShowError = false; // キャンセルの場合は何もしない
    } else if (errorString.contains('権限') ||
        errorString.contains('permission')) {
      errorMessage = 'カメラまたはギャラリーの権限が必要です';
    } else if (errorString.contains('ファイル') || errorString.contains('file')) {
      errorMessage = '画像ファイルの処理に失敗しました';
    } else if (errorString.contains('大きすぎ') || errorString.contains('サイズ')) {
      errorMessage = '画像ファイルが大きすぎます（最大10MB）';
    } else if (errorString.contains('カメラ') || errorString.contains('camera')) {
      errorMessage = 'カメラの初期化に失敗しました';
    }

    if (shouldShowError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '閉じる',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// 権限エラーを処理
  void _handlePermissionError(
    BuildContext context,
    CameraPermissionResult result,
  ) {
    if (!mounted) return;

    String title = 'カメラ権限が必要です';
    String message = '';
    List<Widget> actions = [];

    switch (result) {
      case CameraPermissionResult.denied:
        message = 'カメラを使用するには権限の許可が必要です。';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _permissionService.requestCameraPermission();
            },
            child: const Text('権限を許可'),
          ),
        ];
        break;

      case CameraPermissionResult.permanentlyDenied:
        message = 'カメラ権限が拒否されています。設定画面から権限を有効にしてください。';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _permissionService.openSettings();
            },
            child: const Text('設定を開く'),
          ),
        ];
        break;

      case CameraPermissionResult.restricted:
        message = 'カメラの使用が制限されています。';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ];
        break;

      default:
        message = '不明なエラーが発生しました。';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  /// OCR結果表示ダイアログ（Raw/Normalized切替付き）
  void _showOcrResultDialog(BuildContext context, String rawText) {
    showDialog(
      context: context,
      builder: (context) => _OcrResultDialog(rawText: rawText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.home, size: 64),
                const SizedBox(height: 16),
                const Text('ホーム画面', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                const Text(
                  'スナップ日記と日本語学習のメイン画面',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                if (settingsService.srsPreviewEnabled) ...[
                  const SrsPreviewCard(),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              '今日のスナップ',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('写真を撮って日本語学習を始めましょう！'),
                        const SizedBox(height: 12),
                        // メインの撮影ボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _captureAndOcr(context),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('撮影してOCR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // サブボタン行
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _selectFromGalleryAndOcr(context),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('ギャラリー'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _testOcr(context),
                                icon: const Icon(Icons.text_fields),
                                label: const Text('テスト'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// OCR結果表示ダイアログウィジェット
class _OcrResultDialog extends StatefulWidget {
  final String rawText;

  const _OcrResultDialog({required this.rawText});

  @override
  State<_OcrResultDialog> createState() => _OcrResultDialogState();
}

class _OcrResultDialogState extends State<_OcrResultDialog> {
  bool _showNormalized = true;
  late String _normalizedText;

  @override
  void initState() {
    super.initState();
    _normalizedText = TextNormalizer.normalizeOcrText(widget.rawText);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _showNormalized ? _normalizedText : widget.rawText;
    final hasChanges = widget.rawText != _normalizedText;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.text_fields, color: Colors.blue),
          SizedBox(width: 8),
          Text('OCR結果'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Raw/Normalized切替タブ
            if (hasChanges) ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showNormalized = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_showNormalized ? Colors.blue[100] : Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Raw',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showNormalized = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _showNormalized ? Colors.blue[100] : Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Normalized',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // テキスト表示
            Text(
              _showNormalized ? '整形されたテキスト:' : '生のテキスト:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                displayText.isEmpty ? 'テキストが検出されませんでした' : displayText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // 整形情報（Normalized表示時のみ）
            if (_showNormalized && hasChanges) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'テキストが整形されました',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        if (displayText.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () => _copyToClipboard(context, displayText),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('コピー'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        if (widget.rawText.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('学習リストへの追加機能は今後実装予定です')),
              );
            },
            child: const Text('学習に追加'),
          ),
      ],
    );
  }

  /// クリップボードにコピー
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_showNormalized ? "整形された" : "生の"}テキストをコピーしました'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
