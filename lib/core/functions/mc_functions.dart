// ignore: avoid_web_libraries_in_flutter
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import '../helpers/image_url_helper.dart';

class McFunctions {
  static void changePageTitle(String newTitle) {
    html.document.title = newTitle;
  }

  static Future<String> getReleaseVersion() async {
    final contents = await rootBundle.loadString('pubspec.yaml');
    final lines = contents.split('\n');
    for (var line in lines) {
      if (line.startsWith('version:')) {
        final version = line.split(':').last.trim();
        return version;
      }
    }
    return 'Error: Versión no encontrada';
  }

  Future<Uint8List> fetchImageAsUint8List(String url) async {
    // Procesar la URL para obtener la directa si es proxy
    // final processedUrl = ImageUrlHelper.processUrl(url); // No se usa directamente, solo los fallbacks
    final fallbackUrls = ImageUrlHelper.generateFallbackUrls(url);

    Exception? lastError;
    for (final tryUrl in fallbackUrls) {
      try {
        final response = await http.get(Uri.parse(tryUrl));
        if (response.statusCode == 200) {
          String? contentType = response.headers['content-type'];
          if (contentType != null && contentType.startsWith('image/')) {
            return response.bodyBytes;
          } else {
            lastError = Exception('La URL no contiene una imagen');
          }
        } else {
          lastError = Exception('Failed to load image: ${response.statusCode}');
        }
      } catch (e) {
        lastError = Exception('Error al cargar imagen: $e');
      }
    }
    throw lastError ?? Exception('No se pudo cargar la imagen');
  }
}
