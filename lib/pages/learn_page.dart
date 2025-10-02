import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              '学習画面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'SRS（間隔反復学習）システム',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
