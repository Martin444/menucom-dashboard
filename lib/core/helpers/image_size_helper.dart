import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Helper para obtener tamaño y reducir imágenes antes de subirlas.
/// Solo funciona en plataformas nativas (no web).
class ImageSizeHelper {
  /// Devuelve el tamaño (ancho, alto) de la imagen en bytes.
  static Size? getImageSize(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image != null) {
      return Size(image.width.toDouble(), image.height.toDouble());
    }
    return null;
  }

  /// Reduce la imagen a un tamaño máximo y devuelve los nuevos bytes.
  /// Si la imagen ya es menor, la devuelve igual.
  static Uint8List resizeIfNeeded(Uint8List bytes, {int maxWidth = 1000, int maxHeight = 1000}) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    if (image.width <= maxWidth && image.height <= maxHeight) {
      return bytes;
    }
    final resized = img.copyResize(image, width: maxWidth, height: maxHeight);
    return Uint8List.fromList(img.encodeJpg(resized));
  }
}

/// Simple clase Size para ancho/alto
class Size {
  final double width;
  final double height;
  const Size(this.width, this.height);
}
