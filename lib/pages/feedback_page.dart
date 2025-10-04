import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/diagnostics_service.dart';

/// フィードバックのカテゴリ
enum FeedbackCategory {
  bug('Bug Report', 'Report a technical issue or unexpected behavior'),
  feature('Feature Request', 'Suggest a new feature or improvement'),
  question('Question', 'Ask a question about the app'),
  other('Other', 'General feedback or other inquiries');

  const FeedbackCategory(this.title, this.description);
  final String title;
  final String description;
}

/// フィードバックフォーム
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  FeedbackCategory _selectedCategory = FeedbackCategory.bug;
  bool _includeDiagnostics = true;
  bool _agreedToPrivacy = false;
  bool _isGeneratingDiagnostics = false;
  bool _isSending = false;

  final DiagnosticsService _diagnosticsService = DiagnosticsService();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildSubjectSection(),
              const SizedBox(height: 24),
              _buildMessageSection(),
              const SizedBox(height: 24),
              _buildDiagnosticsSection(),
              const SizedBox(height: 24),
              _buildPrivacySection(),
              const SizedBox(height: 32),
              _buildPreviewButton(),
              const SizedBox(height: 16),
              _buildSendButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// カテゴリ選択セクション
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...FeedbackCategory.values
            .map((category) => RadioListTile<FeedbackCategory>(
                  title: Text(category.title),
                  subtitle: Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                )),
      ],
    );
  }

  /// 件名入力セクション
  Widget _buildSubjectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(
            hintText: 'Brief description of your feedback',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a subject';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// メッセージ入力セクション
  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText:
                'Please provide detailed information about your feedback...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a message';
            }
            if (value.trim().length < 10) {
              return 'Please provide more details (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 診断情報セクション
  Widget _buildDiagnosticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Diagnostic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Include anonymous diagnostic information to help us understand and fix issues faster. This includes app version, device info, and recent error logs.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Include diagnostic information'),
              subtitle: _includeDiagnostics
                  ? Text(
                      'Will include app version, device info, and error logs',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    )
                  : null,
              value: _includeDiagnostics,
              onChanged: (value) {
                setState(() {
                  _includeDiagnostics = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// プライバシー同意セクション
  Widget _buildPrivacySection() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy Notice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Diagnostic information includes anonymous app and device data only. No personal information, photos, or learning data will be shared.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[700],
                  ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(
                'I agree to share diagnostic information',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: _agreedToPrivacy,
              onChanged: _includeDiagnostics
                  ? (value) {
                      setState(() {
                        _agreedToPrivacy = value ?? false;
                      });
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// プレビューボタン
  Widget _buildPreviewButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isGeneratingDiagnostics ? null : _previewDiagnostics,
        icon: _isGeneratingDiagnostics
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.preview),
        label: Text(
            _isGeneratingDiagnostics ? 'Generating...' : 'Preview Diagnostics'),
      ),
    );
  }

  /// 送信ボタン
  Widget _buildSendButtons() {
    final canSend = _formKey.currentState?.validate() == true &&
        (!_includeDiagnostics || _agreedToPrivacy);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canSend && !_isSending ? _sendViaEmail : null,
            icon: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.email),
            label: Text(_isSending ? 'Sending...' : 'Send via Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: canSend && !_isSending ? _sendViaShare : null,
            icon: const Icon(Icons.share),
            label: const Text('Send via Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// 診断情報をプレビュー
  Future<void> _previewDiagnostics() async {
    if (!_includeDiagnostics) return;

    setState(() {
      _isGeneratingDiagnostics = true;
    });

    try {
      final preview = await _diagnosticsService.getDiagnosticsPreview();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Diagnostic Information Preview'),
            content: SingleChildScrollView(
              child: SelectableText(
                preview,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingDiagnostics = false;
      });
    }
  }

  /// メールで送信
  Future<void> _sendViaEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_includeDiagnostics && !_agreedToPrivacy) return;

    setState(() {
      _isSending = true;
    });

    try {
      final subject = '${_selectedCategory.title}: ${_subjectController.text}';
      final body = _buildEmailBody();

      String? diagnosticsPath;
      if (_includeDiagnostics) {
        diagnosticsPath = await _diagnosticsService.saveDiagnosticsToFile();
      }

      final uri = Uri(
        scheme: 'mailto',
        path: 'support@snapjplearn.com', // 実際のサポートメールアドレスに変更
        query: _buildMailtoQuery(subject, body, diagnosticsPath),
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email app opened with your feedback'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Cannot launch email app');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// 共有で送信
  Future<void> _sendViaShare() async {
    if (!_formKey.currentState!.validate()) return;
    if (_includeDiagnostics && !_agreedToPrivacy) return;

    setState(() {
      _isSending = true;
    });

    try {
      final subject = '${_selectedCategory.title}: ${_subjectController.text}';
      final body = _buildEmailBody();

      if (_includeDiagnostics) {
        final diagnosticsPath =
            await _diagnosticsService.saveDiagnosticsToFile();
        if (diagnosticsPath != null) {
          await Share.shareXFiles(
            [XFile(diagnosticsPath)],
            text: '$subject\n\n$body',
            subject: subject,
          );
        } else {
          await Share.share('$subject\n\n$body', subject: subject);
        }
      } else {
        await Share.share('$subject\n\n$body', subject: subject);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// メール本文を構築
  String _buildEmailBody() {
    final buffer = StringBuffer();
    buffer.writeln('Category: ${_selectedCategory.title}');
    buffer.writeln();
    buffer.writeln('Message:');
    buffer.writeln(_messageController.text);
    buffer.writeln();

    if (_includeDiagnostics) {
      buffer.writeln('---');
      buffer.writeln(
          'Diagnostic information has been attached to help with troubleshooting.');
    }

    return buffer.toString();
  }

  /// メールtoクエリを構築
  String _buildMailtoQuery(
      String subject, String body, String? diagnosticsPath) {
    final params = <String>[
      'subject=${Uri.encodeComponent(subject)}',
      'body=${Uri.encodeComponent(body)}',
    ];

    if (diagnosticsPath != null) {
      // 実際の実装では、メールアプリに添付ファイルを渡すのは複雑
      // ここでは診断情報が添付されたことを本文に記載
      params.add(
          'body=${Uri.encodeComponent("$body\n\nDiagnostic file: $diagnosticsPath")}');
    }

    return params.join('&');
  }
}
