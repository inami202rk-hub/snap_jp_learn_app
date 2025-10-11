import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../generated/app_localizations.dart';
import '../services/onboarding_service.dart';
import 'home_page.dart';

/// 初回起動時のオンボーディング画面
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // テスト環境などでローカライゼーションが利用できない場合のフォールバック
    if (l10n == null) {
      return _buildFallbackOnboarding(context);
    }

    return IntroductionScreen(
      pages: [
        _buildPageViewModel(
          title: l10n.onboardTitle1,
          description: l10n.onboardDesc1,
          image: _buildImageWidget(Icons.camera_alt, Colors.blue),
        ),
        _buildPageViewModel(
          title: l10n.onboardTitle2,
          description: l10n.onboardDesc2,
          image: _buildImageWidget(Icons.text_fields, Colors.green),
        ),
        _buildPageViewModel(
          title: l10n.onboardTitle3,
          description: l10n.onboardDesc3,
          image: _buildImageWidget(Icons.school, Colors.orange),
        ),
        _buildPageViewModel(
          title: l10n.onboardTitle4,
          description: l10n.onboardDesc4,
          image: _buildImageWidget(Icons.analytics, Colors.purple),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skip: Text(l10n.skip),
      next: Text(l10n.next),
      done: Text(l10n.done),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    );
  }

  /// ページビューモデルを作成
  PageViewModel _buildPageViewModel({
    required String title,
    required String description,
    required Widget image,
  }) {
    return PageViewModel(
      title: title,
      body: description,
      image: image,
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 19.0,
        ),
        imagePadding: EdgeInsets.only(top: 120),
        pageColor: Colors.white,
      ),
    );
  }

  /// 画像ウィジェットを作成
  Widget _buildImageWidget(IconData icon, Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 100,
        color: color,
      ),
    );
  }

  /// フォールバック用のオンボーディング画面（テスト環境など）
  Widget _buildFallbackOnboarding(BuildContext context) {
    return IntroductionScreen(
      pages: [
        _buildPageViewModel(
          title: 'Learn Japanese from Photos',
          description:
              'Take photos of Japanese text and turn them into learning cards instantly',
          image: _buildImageWidget(Icons.camera_alt, Colors.blue),
        ),
        _buildPageViewModel(
          title: 'Extract Text with OCR',
          description:
              'Our smart OCR technology recognizes Japanese characters accurately',
          image: _buildImageWidget(Icons.text_fields, Colors.green),
        ),
        _buildPageViewModel(
          title: 'Study with SRS Cards',
          description:
              'Review your cards using spaced repetition for effective learning',
          image: _buildImageWidget(Icons.school, Colors.orange),
        ),
        _buildPageViewModel(
          title: 'Track Your Progress',
          description:
              'Monitor your learning journey with detailed statistics and insights',
          image: _buildImageWidget(Icons.analytics, Colors.purple),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Text('Next'),
      done: const Text('Done'),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    );
  }

  /// 完了時の処理
  Future<void> _onDone(BuildContext context) async {
    // オンボーディング完了フラグを保存
    await OnboardingService.markOnboardingCompleted();

    // ホームページに遷移（履歴をクリア）
    if (context.mounted) {
      // テスト環境では遷移しない（HomePageがプロバイダーを必要とするため）
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    }
  }
}
