import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeroChineseTypingApp());
}

class HeroChineseTypingApp extends StatelessWidget {
  const HeroChineseTypingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hero Chinese Typing',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: AppPages.pages,
    );
  }
}
