import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

    // Si estamos en web
    if (kIsWeb) {
      // Si es web mobile, reducir a width 800 y mantener aspect ratio
      // No hay una forma directa de detectar mobile en Dart puro, pero puedes usar un width menor por defecto
      if (image.width > 800) {
        final resized = img.copyResize(image, width: 800);
        return Uint8List.fromList(img.encodePng(resized));
      }
      // Si ya es menor, devolver PNG para compatibilidad
      return Uint8List.fromList(img.encodePng(image));
    }

    // Nativo: reducir si supera maxWidth/maxHeight
    if (image.width > maxWidth || image.height > maxHeight) {
      final resized = img.copyResize(image, width: maxWidth, height: maxHeight);
      return Uint8List.fromList(img.encodePng(resized));
    }
    // Si ya es menor, devolver PNG para compatibilidad
    return Uint8List.fromList(img.encodePng(image));
  }
}

/// Simple clase Size para ancho/alto
class Size {
  final double width;
  final double height;
  const Size(this.width, this.height);
}
