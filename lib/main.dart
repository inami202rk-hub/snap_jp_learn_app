import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive初期化
  await Hive.initFlutter();

  // Post型アダプターを登録
  Hive.registerAdapter(PostAdapter());

  runApp(const SnapJpLearnApp());
}
