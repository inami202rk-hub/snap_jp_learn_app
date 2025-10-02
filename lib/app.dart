import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/settings/services/settings_service.dart';
import 'pages/home_page.dart';
import 'pages/feed_page.dart';
import 'pages/learn_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';

class SnapJpLearnApp extends StatelessWidget {
  const SnapJpLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsService()..initialize(),
      child: MaterialApp(
        title: 'Snap JP Learn',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
      ),
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
