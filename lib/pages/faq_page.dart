import 'package:flutter/material.dart';

/// FAQ項目
class FAQItem {
  final String question;
  final String answer;
  final bool isExpanded;

  const FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  FAQItem copyWith({bool? isExpanded}) {
    return FAQItem(
      question: question,
      answer: answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// FAQページ
class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Why does the app need camera and photo permissions?',
      answer:
          'The app uses your camera to take photos of Japanese text for OCR (Optical Character Recognition) and accesses your photo library to select existing images. This allows you to extract Japanese text and create learning cards. All data is processed locally on your device and is never sent to external servers.',
    ),
    FAQItem(
      question: 'Is my data stored securely?',
      answer:
          'Yes, all your learning data (photos, cards, progress) is stored locally on your device using secure local storage. No personal information or learning data is sent to external servers. The app only collects anonymous diagnostic information when you explicitly choose to share feedback.',
    ),
    FAQItem(
      question: 'How do I purchase Pro features?',
      answer:
          'Go to Settings > Pro Features and tap "Upgrade Now". You can choose between monthly subscription or lifetime purchase. Both options unlock unlimited card creation and advanced features. Payment is processed securely through your device\'s app store.',
    ),
    FAQItem(
      question: 'How do I restore my Pro purchase on a new device?',
      answer:
          'On your new device, go to Settings > Pro Features and tap "Restore Purchases". Make sure you\'re signed in with the same Apple ID or Google account used for the original purchase. Your Pro status will be restored automatically.',
    ),
    FAQItem(
      question: 'How do I cancel my Pro subscription?',
      answer:
          'On iOS: Go to Settings > Apple ID > Subscriptions > Snap JP Learn, then tap "Cancel Subscription". On Android: Open Google Play Store > Subscriptions > Snap JP Learn, then tap "Cancel". Your Pro features will remain active until the end of your current billing period.',
    ),
    FAQItem(
      question: 'Can I use the app on multiple devices?',
      answer:
          'Yes! Your Pro features are tied to your Apple ID or Google account. You can install the app on multiple devices and restore your Pro status on each device. However, your learning data (cards, progress) is stored locally on each device and doesn\'t sync automatically.',
    ),
    FAQItem(
      question: 'How do I backup my learning data?',
      answer:
          'Go to Settings > Backup and Restore and tap "Export Backup". This creates a JSON file with all your posts, cards, and learning progress. You can share this file via email, cloud storage, or any method you prefer. To restore, tap "Import Backup" and select your backup file.',
    ),
    FAQItem(
      question: 'How do I restore my learning data?',
      answer:
          'Go to Settings > Backup and Restore and tap "Import Backup". Select your backup JSON file from your device storage. This will restore all your posts, cards, and learning progress. Note: This will replace your current data, so make sure to backup first if needed.',
    ),
    FAQItem(
      question: 'What is SRS (Spaced Repetition System)?',
      answer:
          'SRS is a learning technique that shows you cards at increasing intervals to help you remember them better. Cards you know well appear less frequently, while difficult cards appear more often. This scientifically-proven method helps you learn Japanese vocabulary and kanji more effectively.',
    ),
    FAQItem(
      question: 'How does the app determine when to show me a card for review?',
      answer:
          'The app uses an algorithm based on your performance. If you answer correctly, the card appears less frequently. If you answer incorrectly or need help, the card appears more often. This adaptive system helps you focus on the material you need to practice most.',
    ),
    FAQItem(
      question: 'Can I edit or delete my learning cards?',
      answer:
          'Yes! You can edit cards by tapping on them and selecting "Edit". You can delete individual cards or entire posts. Go to the card/post detail view and look for the edit or delete options. You can also bulk delete cards from the main cards list.',
    ),
    FAQItem(
      question: 'The OCR is not recognizing text correctly. What should I do?',
      answer:
          'For best OCR results: 1) Ensure good lighting, 2) Keep the camera steady, 3) Make sure the text is clearly visible and not blurry, 4) Try taking the photo from a straight angle, 5) Clean text (not handwritten) works better than handwritten text.',
    ),
    FAQItem(
      question: 'How do I report a bug or request a feature?',
      answer:
          'Go to Settings > Help & Feedback > Send Feedback. Choose the appropriate category (Bug Report, Feature Request, or Question), fill in the details, and optionally include diagnostic information to help us understand the issue better. We read all feedback and use it to improve the app.',
    ),
    FAQItem(
      question: 'Is there a limit to how many cards I can create?',
      answer:
          'Free users can create up to 50 cards. Pro users have unlimited card creation. If you reach the limit, you can upgrade to Pro or delete some existing cards to make room for new ones.',
    ),
    FAQItem(
      question: 'Does the app work offline?',
      answer:
          'Yes! The app works completely offline. All features including photo capture, OCR, card creation, and SRS reviews work without an internet connection. The only features that require internet are Pro purchases and feedback submission.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final item = _faqItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                item.question,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
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

/// FAQ検索機能付きページ
class FAQSearchPage extends StatefulWidget {
  const FAQSearchPage({super.key});

  @override
  State<FAQSearchPage> createState() => _FAQSearchPageState();
}

class _FAQSearchPageState extends State<FAQSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredItems = [];
  final List<FAQItem> _allItems = [
    FAQItem(
      question: 'Why does the app need camera and photo permissions?',
      answer:
          'The app uses your camera to take photos of Japanese text for OCR (Optical Character Recognition) and accesses your photo library to select existing images. This allows you to extract Japanese text and create learning cards. All data is processed locally on your device and is never sent to external servers.',
    ),
    FAQItem(
      question: 'Is my data stored securely?',
      answer:
          'Yes, all your learning data (photos, cards, progress) is stored locally on your device using secure local storage. No personal information or learning data is sent to external servers. The app only collects anonymous diagnostic information when you explicitly choose to share feedback.',
    ),
    FAQItem(
      question: 'How do I purchase Pro features?',
      answer:
          'Go to Settings > Pro Features and tap "Upgrade Now". You can choose between monthly subscription or lifetime purchase. Both options unlock unlimited card creation and advanced features. Payment is processed securely through your device\'s app store.',
    ),
    FAQItem(
      question: 'How do I restore my Pro purchase on a new device?',
      answer:
          'On your new device, go to Settings > Pro Features and tap "Restore Purchases". Make sure you\'re signed in with the same Apple ID or Google account used for the original purchase. Your Pro status will be restored automatically.',
    ),
    FAQItem(
      question: 'How do I cancel my Pro subscription?',
      answer:
          'On iOS: Go to Settings > Apple ID > Subscriptions > Snap JP Learn, then tap "Cancel Subscription". On Android: Open Google Play Store > Subscriptions > Snap JP Learn, then tap "Cancel". Your Pro features will remain active until the end of your current billing period.',
    ),
    FAQItem(
      question: 'Can I use the app on multiple devices?',
      answer:
          'Yes! Your Pro features are tied to your Apple ID or Google account. You can install the app on multiple devices and restore your Pro status on each device. However, your learning data (cards, progress) is stored locally on each device and doesn\'t sync automatically.',
    ),
    FAQItem(
      question: 'How do I backup my learning data?',
      answer:
          'Go to Settings > Backup and Restore and tap "Export Backup". This creates a JSON file with all your posts, cards, and learning progress. You can share this file via email, cloud storage, or any method you prefer. To restore, tap "Import Backup" and select your backup file.',
    ),
    FAQItem(
      question: 'How do I restore my learning data?',
      answer:
          'Go to Settings > Backup and Restore and tap "Import Backup". Select your backup JSON file from your device storage. This will restore all your posts, cards, and learning progress. Note: This will replace your current data, so make sure to backup first if needed.',
    ),
    FAQItem(
      question: 'What is SRS (Spaced Repetition System)?',
      answer:
          'SRS is a learning technique that shows you cards at increasing intervals to help you remember them better. Cards you know well appear less frequently, while difficult cards appear more often. This scientifically-proven method helps you learn Japanese vocabulary and kanji more effectively.',
    ),
    FAQItem(
      question: 'How does the app determine when to show me a card for review?',
      answer:
          'The app uses an algorithm based on your performance. If you answer correctly, the card appears less frequently. If you answer incorrectly or need help, the card appears more often. This adaptive system helps you focus on the material you need to practice most.',
    ),
    FAQItem(
      question: 'Can I edit or delete my learning cards?',
      answer:
          'Yes! You can edit cards by tapping on them and selecting "Edit". You can delete individual cards or entire posts. Go to the card/post detail view and look for the edit or delete options. You can also bulk delete cards from the main cards list.',
    ),
    FAQItem(
      question: 'The OCR is not recognizing text correctly. What should I do?',
      answer:
          'For best OCR results: 1) Ensure good lighting, 2) Keep the camera steady, 3) Make sure the text is clearly visible and not blurry, 4) Try taking the photo from a straight angle, 5) Clean text (not handwritten) works better than handwritten text.',
    ),
    FAQItem(
      question: 'How do I report a bug or request a feature?',
      answer:
          'Go to Settings > Help & Feedback > Send Feedback. Choose the appropriate category (Bug Report, Feature Request, or Question), fill in the details, and optionally include diagnostic information to help us understand the issue better. We read all feedback and use it to improve the app.',
    ),
    FAQItem(
      question: 'Is there a limit to how many cards I can create?',
      answer:
          'Free users can create up to 50 cards. Pro users have unlimited card creation. If you reach the limit, you can upgrade to Pro or delete some existing cards to make room for new ones.',
    ),
    FAQItem(
      question: 'Does the app work offline?',
      answer:
          'Yes! The app works completely offline. All features including photo capture, OCR, card creation, and SRS reviews work without an internet connection. The only features that require internet are Pro purchases and feedback submission.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item.question.toLowerCase().contains(query) ||
              item.answer.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(
                            item.question,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                item.answer,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
