// ignore: avoid_web_libraries_in_flutter
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/services.dart' show Uint8List, rootBundle;

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
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String? contentType = response.headers['content-type'];
      if (contentType != null && contentType.startsWith('image/')) {
        return response.bodyBytes;
      } else {
        throw Exception('La URL no contiene una imagen');
      }
    } else {
      throw Exception('Failed to load image');
    }
  }
}
