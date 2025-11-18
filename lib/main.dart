import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChineseLearningApp());
}

class ChineseLearningApp extends StatelessWidget {
  const ChineseLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chinese Learning',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: AppPages.pages,
    );
  }
}
