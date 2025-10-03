import 'dart:io';
import 'package:image/image.dart' as img;

/// Utility class for image validation and safety checks
class ImageValidator {
  static const int maxFileSizeMB = 10; // 10MB limit
  static const int maxWidth = 4000; // 4K width limit
  static const int maxHeight = 4000; // 4K height limit

  /// Check if image file is within acceptable size limits
  static Future<bool> isImageValid(File imageFile) async {
    try {
      // Check file size
      final fileSizeBytes = await imageFile.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > maxFileSizeMB) {
        return false;
      }

      // Check image dimensions
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return false;
      }

      if (image.width > maxWidth || image.height > maxHeight) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get image dimensions
  static Future<({int width, int height})?> getImageDimensions(
      File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return null;
      }

      return (width: image.width, height: image.height);
    } catch (e) {
      return null;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final fileSizeBytes = await file.length();
    return fileSizeBytes / (1024 * 1024);
  }
}
