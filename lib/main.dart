import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/post.dart';
import 'models/srs_card.dart';
import 'models/review_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive初期化
  await Hive.initFlutter();

  // 型アダプターを登録
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(SrsCardAdapter());
  Hive.registerAdapter(ReviewLogAdapter());

  runApp(const SnapJpLearnApp());
}
