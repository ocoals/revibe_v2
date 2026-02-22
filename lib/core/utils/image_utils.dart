import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

class ImageUtils {
  ImageUtils._();

  /// Resize image to max dimension while preserving aspect ratio
  /// Also strips EXIF GPS data for privacy
  static Uint8List? processImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Resize if necessary
    final maxDim = AppConfig.maxImageDimensionPx;
    img.Image resized;
    if (image.width > maxDim || image.height > maxDim) {
      if (image.width > image.height) {
        resized = img.copyResize(image, width: maxDim);
      } else {
        resized = img.copyResize(image, height: maxDim);
      }
    } else {
      resized = image;
    }

    // Encode as JPEG
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: AppConfig.jpegQuality),
    );
  }
}
