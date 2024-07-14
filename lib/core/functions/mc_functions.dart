// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;

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
}
