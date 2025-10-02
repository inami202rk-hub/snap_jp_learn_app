import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'フィード画面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              '投稿された写真と学習記録を表示',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
