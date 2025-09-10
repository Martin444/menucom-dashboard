#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script para sincronizar configuraciones entre .vscode/launch.json y netlify.toml
/// Ejecutar con: dart scripts/sync_configs.dart
void main() async {
  print('🔄 Iniciando sincronización de configuraciones...');

  try {
    // Leer configuraciones de launch.json
    final launchConfig = await _readLaunchConfig();

    // Extraer variables de entorno
    final envVars = _extractEnvironmentVariables(launchConfig);

    // Actualizar netlify.toml
    await _updateNetlifyConfig(envVars);

    print('✅ Sincronización completada exitosamente');
    print('📋 Variables sincronizadas:');
    envVars.forEach((key, value) => print('   $key'));
  } catch (e) {
    print('❌ Error durante la sincronización: $e');
    exit(1);
  }
}

Future<Map<String, dynamic>> _readLaunchConfig() async {
  final file = File('.vscode/launch.json');

  if (!file.existsSync()) {
    throw Exception('Archivo .vscode/launch.json no encontrado');
  }

  final content = await file.readAsString();

  // Limpiar comentarios JSON-C
  final cleanContent =
      content.replaceAll(RegExp(r'//.*'), '').replaceAll(RegExp(r'/\*.*?\*/', multiLine: true, dotAll: true), '');

  return jsonDecode(cleanContent);
}

Map<String, String> _extractEnvironmentVariables(Map<String, dynamic> config) {
  final Map<String, String> envVars = {};

  final configurations = config['configurations'] as List;

  // Buscar configuración de QA (la que usa Netlify por defecto)
  final qaConfig = configurations.firstWhere(
    (conf) => conf['name'] == 'qa_menucom',
    orElse: () => configurations.first,
  );

  final args = qaConfig['args'] as List<String>;

  for (final arg in args) {
    if (arg.startsWith('--dart-define=')) {
      final define = arg.substring('--dart-define='.length);
      final parts = define.split('=');
      if (parts.length == 2) {
        envVars[parts[0]] = parts[1];
      }
    }
  }

  return envVars;
}

Future<void> _updateNetlifyConfig(Map<String, String> envVars) async {
  final file = File('netlify.toml');

  // Generar comando de build con todas las variables
  final buildArgs = envVars.entries.map((entry) => '--dart-define=${entry.key}=${entry.value}').join(' ');

  final qaCommand = 'flutter build web --release --web-renderer html $buildArgs';

  // Comando para producción (usar API de DigitalOcean)
  final prodEnvVars = Map<String, String>.from(envVars);
  prodEnvVars['API_URL'] = 'https://hammerhead-app-pouq5.ondigitalocean.app';

  final prodBuildArgs = prodEnvVars.entries.map((entry) => '--dart-define=${entry.key}=${entry.value}').join(' ');

  final prodCommand = 'flutter build web --release --web-renderer html $prodBuildArgs';

  final netlifyConfig = '''
[build]
    command = "$qaCommand"
    publish = "build/web"

# Variables de entorno para el despliegue (para referencia)
[build.environment]
${envVars.entries.map((e) => '    ${e.key} = "${e.value}"').join('\n')}

# Configuración para branch-specific deployments
[context.production]
    command = "$prodCommand"

[context.deploy-preview]
    command = "$qaCommand"

# Headers de seguridad para aplicaciones web
[[headers]]
    for = "/*"
    [headers.values]
        X-Frame-Options = "DENY"
        X-XSS-Protection = "1; mode=block"
        X-Content-Type-Options = "nosniff"
        Referrer-Policy = "strict-origin-when-cross-origin"
        Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://apis.google.com https://accounts.google.com https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://menucom-api-60e608ae2f99.herokuapp.com https://hammerhead-app-pouq5.ondigitalocean.app https://identitytoolkit.googleapis.com https://securetoken.googleapis.com https://www.googleapis.com; frame-src https://accounts.google.com;"

# Redirects para SPA
[[redirects]]
    from = "/*"
    to = "/index.html"
    status = 200
''';

  await file.writeAsString(netlifyConfig);
  print('📝 Archivo netlify.toml actualizado');
}
