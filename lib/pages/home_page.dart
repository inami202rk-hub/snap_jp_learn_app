import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/settings/services/settings_service.dart';
import '../widgets/srs_preview_card.dart';
import '../services/ocr_service.dart';
import '../services/ocr_service_mlkit.dart';
import '../services/camera_permission_service.dart';

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
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
        
        // 結果をダイアログで表示
        _showOcrResultDialog(context, extractedText);
      }
    } catch (e) {
      // エラー処理
      _handleOcrError(context, e);
    }
  }

  /// カメラ撮影からOCR処理までのフロー
  Future<void> _captureAndOcr(BuildContext context) async {
    try {
      // カメラ権限を確認
      final permissionResult = await _permissionService.ensureCameraPermission();
      
      if (permissionResult != CameraPermissionResult.granted) {
        _handlePermissionError(context, permissionResult);
        return;
      }

      // ローディング表示
      _showLoadingDialog(context, '撮影準備中...');

      // カメラで撮影してOCR処理
      final extractedText = await (_ocrService as OcrServiceMlkit).captureAndExtractText();

      // ローディング終了
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
        
        // 結果をダイアログで表示
        _showOcrResultDialog(context, extractedText);
      }
    } catch (e) {
      // エラー処理
      _handleOcrError(context, e);
    }
  }

  /// ギャラリーから画像選択してOCR処理
  Future<void> _selectFromGalleryAndOcr(BuildContext context) async {
    try {
      // ローディング表示
      _showLoadingDialog(context, '画像選択中...');

      // ギャラリーから選択してOCR処理
      final extractedText = await (_ocrService as OcrServiceMlkit).selectFromGalleryAndExtractText();

      // ローディング終了
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
        
        // 結果をダイアログで表示
        _showOcrResultDialog(context, extractedText);
      }
    } catch (e) {
      // エラー処理
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
    if (!context.mounted) return;
    
    Navigator.of(context).pop(); // ローディング終了
    
    String errorMessage = 'OCRエラーが発生しました';
    if (error.toString().contains('キャンセル')) {
      return; // キャンセルの場合は何もしない
    } else if (error.toString().contains('権限')) {
      errorMessage = 'カメラの権限が必要です';
    } else if (error.toString().contains('ファイル')) {
      errorMessage = '画像ファイルの処理に失敗しました';
    }
    
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

  /// 権限エラーを処理
  void _handlePermissionError(BuildContext context, CameraPermissionResult result) {
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

  /// OCR結果表示ダイアログ
  void _showOcrResultDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              const Text(
                '抽出されたテキスト:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                child: Text(
                  text.isEmpty ? 'テキストが検出されませんでした' : text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          if (text.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // TODO: 将来的にSRS学習に追加する機能
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('学習リストへの追加機能は今後実装予定です')),
                );
              },
              child: const Text('学習に追加'),
            ),
        ],
      ),
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
                const Icon(
                  Icons.home,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ホーム画面',
                  style: TextStyle(fontSize: 24),
                ),
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                                onPressed: () => _selectFromGalleryAndOcr(context),
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
