import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/injection_bindings.dart';
import 'routes/pages.dart';

void main() {
  getToken();
  runApp(const MyApp());
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String?> getToken() async {
  var prefs = await _prefs;
  var token = prefs.getString('acccesstoken');
  if (token != null) {
    ACCESS_TOKEN = token;
  }
  return token;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MenuCom Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        drawerTheme: DrawerThemeData(
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: PUColors.primaryColor,
        ),
        useMaterial3: true,
      ),
      initialRoute: PURoutes.HOME,
      getPages: PUPages.listPages,
      initialBinding: MainBindings(),
    );
  }
}
