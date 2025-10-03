import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/utils/image_validator.dart';

void main() {
  group('ImageValidator Tests', () {
    test('ImageValidator constants are defined correctly', () {
      expect(ImageValidator.maxFileSizeMB, equals(10));
      expect(ImageValidator.maxWidth, equals(4000));
      expect(ImageValidator.maxHeight, equals(4000));
    });

    test('getFileSizeMB returns correct size for test file', () async {
      // Create a temporary test file
      final tempFile = File('test_image.txt');
      await tempFile.writeAsString('test content');

      try {
        final sizeMB = await ImageValidator.getFileSizeMB(tempFile);
        expect(sizeMB, greaterThan(0));
        expect(sizeMB, lessThan(0.001)); // Should be very small
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('getImageDimensions returns null for non-image file', () async {
      // Create a temporary text file (not an image)
      final tempFile = File('test_text.txt');
      await tempFile.writeAsString('This is not an image');

      try {
        final dimensions = await ImageValidator.getImageDimensions(tempFile);
        expect(dimensions, isNull);
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('isImageValid returns false for non-image file', () async {
      // Create a temporary text file (not an image)
      final tempFile = File('test_text.txt');
      await tempFile.writeAsString('This is not an image');

      try {
        final isValid = await ImageValidator.isImageValid(tempFile);
        expect(isValid, isFalse);
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('isImageValid returns false for non-existent file', () async {
      final nonExistentFile = File('non_existent_file.jpg');
      final isValid = await ImageValidator.isImageValid(nonExistentFile);
      expect(isValid, isFalse);
    });

    test('getImageDimensions returns null for non-existent file', () async {
      final nonExistentFile = File('non_existent_file.jpg');
      final dimensions =
          await ImageValidator.getImageDimensions(nonExistentFile);
      expect(dimensions, isNull);
    });

    test('getFileSizeMB throws exception for non-existent file', () async {
      final nonExistentFile = File('non_existent_file.jpg');

      expect(
        () async => await ImageValidator.getFileSizeMB(nonExistentFile),
        throwsA(isA<Exception>()),
      );
    });
  });
}
