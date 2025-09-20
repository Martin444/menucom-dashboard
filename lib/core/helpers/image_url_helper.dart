/// Helper para procesamiento y validación de URLs de imágenes protegidas por proxy.
/// Modular y reutilizable para todo el proyecto.
library;

import 'package:flutter/foundation.dart';

class ImageUrlHelper {
  /// Procesa una URL de imagen, extrayendo la URL directa si es proxy.
  static String processUrl(String url) {
    final cleanedUrl = url.trim().replaceAll(RegExp(r'\s+'), '');

    // Proxy localhost
    if (cleanedUrl.contains('localhost') && cleanedUrl.contains('image-proxy') && cleanedUrl.contains('url=')) {
      try {
        final uri = Uri.parse(cleanedUrl);
        final encodedUrl = uri.queryParameters['url'];
        if (encodedUrl != null) {
          return Uri.decodeComponent(encodedUrl);
        }
      } catch (_) {}
    }

    // Proxy Heroku/API
    if (cleanedUrl.contains('menucom-api') && cleanedUrl.contains('image-proxy') && cleanedUrl.contains('url=')) {
      try {
        final uri = Uri.parse(cleanedUrl);
        final encodedUrl = uri.queryParameters['url'];
        if (encodedUrl != null) {
          return Uri.decodeComponent(encodedUrl);
        }
      } catch (_) {}
    }

    // URL directa Cloudinary
    if (cleanedUrl.contains('res.cloudinary.com')) {
      return cleanedUrl;
    }

    return cleanedUrl;
  }

  /// Genera una lista de URLs de fallback para una imagen.
  static List<String> generateFallbackUrls(String originalUrl) {
    final urls = <String>[];
    urls.add(originalUrl);
    if (originalUrl.contains('image-proxy') && originalUrl.contains('url=')) {
      try {
        final uri = Uri.parse(originalUrl);
        final encodedUrl = uri.queryParameters['url'];
        if (encodedUrl != null) {
          final directUrl = Uri.decodeComponent(encodedUrl);
          if (directUrl != originalUrl && !urls.contains(directUrl)) {
            urls.add(directUrl);
          }
        }
      } catch (_) {}
    }
    return urls;
  }

  /// Valida si una URL es válida para cargar una imagen.
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
