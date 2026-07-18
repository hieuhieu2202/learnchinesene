import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'screen/splash/splash_screen.dart';

class ChineseMasterApp extends StatelessWidget {
  const ChineseMasterApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: 'Học tiếng Trung',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      );
}
