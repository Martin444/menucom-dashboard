// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:flutter/foundation.dart';

class Config {
  static const String accessTokenSecretKey = String.fromEnvironment(
    'ACCESS_TOKEN_SECRET_KEY',
    defaultValue: "",
  );

  static const String baseUrlApi = String.fromEnvironment(
    'API_URL',
    defaultValue: "https://api.menucom.com", // Placeholder, adjust as needed
  );

  static String baseUrl = kIsWeb
      ? 'https://menucom-dashboard.netlify.app'
      : 'https://menucom-dashboard.netlify.app'; // Adjust for production

  static const String mpClientId = String.fromEnvironment(
    'MP_CLIENT_ID',
    defaultValue: "8524412211477757", // Example ID, replace with real one
  );

  static String versionApp = '2.0.7';
  static String urlMenuOrigin = String.fromEnvironment(
    'URL_MENU_ORIGIN',
    defaultValue: 'https://menu-comerce.netlify.app',
  );
  static String mpRedirectUri = String.fromEnvironment(
    'MP_REDIRECT_URI',
    defaultValue: 'https://menucom-api.onrender.com/payments/oauth/callback',
  );
}

// Keep global constants for backward compatibility if needed
const String URL_PICKME_API = Config.baseUrlApi;
String URL_MENU_ORIGIN = Config.urlMenuOrigin;
var VERSION_APP = Config.versionApp;
