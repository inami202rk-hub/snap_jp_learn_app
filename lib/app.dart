import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'features/settings/services/settings_service.dart';
import 'pages/home_page.dart';
import 'pages/feed_page.dart';
import 'pages/learn_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'pages/onboarding_page.dart';
import 'services/stats_service.dart';
import 'services/onboarding_service.dart';
import 'services/hive_maintenance_service.dart';
import 'repositories/srs_repository.dart';
import 'repositories/srs_repository_impl.dart';
import 'repositories/post_repository.dart';
import 'repositories/post_repository_impl.dart';
import 'data/local/srs_local_data_source.dart';
import 'data/local/post_local_data_source.dart';

class SnapJpLearnApp extends StatelessWidget {
  const SnapJpLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsService()..initialize(),
        ),
        Provider<SrsRepository>(
          create: (context) => SrsRepositoryImpl(SrsLocalDataSource()),
          lazy: true,
        ),
        Provider<PostRepository>(
          create: (context) => PostRepositoryImpl(PostLocalDataSource()),
          lazy: true,
        ),
        Provider<StatsService>(
          create: (context) {
            final srsRepo = context.read<SrsRepository>();
            final postRepo = context.read<PostRepository>();
            final statsService = StatsService(
              srsRepository: srsRepo,
              postRepository: postRepo,
            );
            if (srsRepo is SrsRepositoryImpl) {
              srsRepo.setStatsService(statsService);
            }
            return statsService;
          },
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'Snap JP Learn',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

/// アプリの初期化とオンボーディング判定を行うウィジェット
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 並列で実行する初期化タスク
    final initTasks = [
      _checkOnboardingStatus(),
      _initializeDataSources(),
      _performBackgroundMaintenance(),
    ];

    // オンボーディングチェックを優先して実行
    final onboardingResult = await initTasks[0] as bool;

    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingResult;
        _isLoading = false;
      });
    }

    // バックグラウンドで残りの初期化を実行
    Future.wait(initTasks.skip(1));
  }

  Future<bool> _checkOnboardingStatus() async {
    return await OnboardingService.isOnboardingCompleted();
  }

  Future<void> _initializeDataSources() async {
    try {
      // データソースの初期化を遅延実行
      final srsDataSource = SrsLocalDataSource();
      final postDataSource = PostLocalDataSource();

      // 並列で初期化
      await Future.wait([
        srsDataSource.init(),
        postDataSource.init(),
      ]);
    } catch (e) {
      // エラーログを出力（必要に応じてLogServiceを使用）
      debugPrint('Data source initialization error: $e');
    }
  }

  Future<void> _performBackgroundMaintenance() async {
    try {
      // 週1回のメンテナンスタスクを実行
      await Future.wait([
        HiveMaintenanceService.performCompactionIfNeeded(),
        HiveMaintenanceService.performOrphanCleanup(),
      ]);
    } catch (e) {
      debugPrint('Background maintenance error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return const OnboardingPage();
    }

    return ShowCaseWidget(
      builder: (context) => const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FeedPage(),
    LearnPage(),
    StatsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
