import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/post.dart';

void main() {
  group('Post Model Tests', () {
    test('Post should be created with required fields', () {
      final now = DateTime.now();
      final post = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
      );

      expect(post.id, 'test-id');
      expect(post.imagePath, '/path/to/image.jpg');
      expect(post.rawText, 'Raw text');
      expect(post.normalizedText, 'Normalized text');
      expect(post.createdAt, now);
      expect(post.likeCount, 0);
      expect(post.learnedCount, 0);
      expect(post.learned, false);
    });

    test('Post should be created with custom fields', () {
      final now = DateTime.now();
      final post = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
        likeCount: 5,
        learnedCount: 3,
        learned: true,
      );

      expect(post.likeCount, 5);
      expect(post.learnedCount, 3);
      expect(post.learned, true);
    });

    test('Post copyWith should create new instance with updated fields', () {
      final now = DateTime.now();
      final originalPost = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
        likeCount: 1,
        learnedCount: 2,
        learned: false,
      );

      final updatedPost = originalPost.copyWith(likeCount: 10, learned: true);

      // 元のオブジェクトは変更されない
      expect(originalPost.likeCount, 1);
      expect(originalPost.learned, false);

      // 新しいオブジェクトは更新される
      expect(updatedPost.id, 'test-id');
      expect(updatedPost.imagePath, '/path/to/image.jpg');
      expect(updatedPost.rawText, 'Raw text');
      expect(updatedPost.normalizedText, 'Normalized text');
      expect(updatedPost.createdAt, now);
      expect(updatedPost.likeCount, 10);
      expect(updatedPost.learnedCount, 2);
      expect(updatedPost.learned, true);
    });

    test('Post toJson should serialize correctly', () {
      final now = DateTime.now();
      final post = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
        likeCount: 5,
        learnedCount: 3,
        learned: true,
      );

      final json = post.toJson();

      expect(json['id'], 'test-id');
      expect(json['imagePath'], '/path/to/image.jpg');
      expect(json['rawText'], 'Raw text');
      expect(json['normalizedText'], 'Normalized text');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['likeCount'], 5);
      expect(json['learnedCount'], 3);
      expect(json['learned'], true);
    });

    test('Post fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'imagePath': '/path/to/image.jpg',
        'rawText': 'Raw text',
        'normalizedText': 'Normalized text',
        'createdAt': now.toIso8601String(),
        'likeCount': 5,
        'learnedCount': 3,
        'learned': true,
      };

      final post = Post.fromJson(json);

      expect(post.id, 'test-id');
      expect(post.imagePath, '/path/to/image.jpg');
      expect(post.rawText, 'Raw text');
      expect(post.normalizedText, 'Normalized text');
      expect(post.createdAt, now);
      expect(post.likeCount, 5);
      expect(post.learnedCount, 3);
      expect(post.learned, true);
    });

    test('Post fromJson should handle missing optional fields', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'imagePath': '/path/to/image.jpg',
        'rawText': 'Raw text',
        'normalizedText': 'Normalized text',
        'createdAt': now.toIso8601String(),
      };

      final post = Post.fromJson(json);

      expect(post.id, 'test-id');
      expect(post.imagePath, '/path/to/image.jpg');
      expect(post.rawText, 'Raw text');
      expect(post.normalizedText, 'Normalized text');
      expect(post.createdAt, now);
      expect(post.likeCount, 0);
      expect(post.learnedCount, 0);
      expect(post.learned, false);
    });

    test('Post equality should work correctly', () {
      final now = DateTime.now();
      final post1 = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
      );

      final post2 = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
      );

      final post3 = Post(
        id: 'different-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
      );

      expect(post1, equals(post2));
      expect(post1, isNot(equals(post3)));
      expect(post1.hashCode, equals(post2.hashCode));
      expect(post1.hashCode, isNot(equals(post3.hashCode)));
    });

    test('Post toString should return readable string', () {
      final now = DateTime.now();
      final post = Post(
        id: 'test-id',
        imagePath: '/path/to/image.jpg',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: now,
        likeCount: 5,
        learnedCount: 3,
        learned: true,
      );

      final string = post.toString();
      expect(string, contains('test-id'));
      expect(string, contains('/path/to/image.jpg'));
      expect(string, contains('Raw text'));
      expect(string, contains('Normalized text'));
      expect(string, contains('5'));
      expect(string, contains('3'));
      expect(string, contains('true'));
    });
  });
}
