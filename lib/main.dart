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
    // ⭐ Tạo RouteObserver cục bộ (không dùng Get.find)
    final routeObserver = RouteObserver<ModalRoute<dynamic>>();

    return GetMaterialApp(
      title: 'Hero Chinese Typing',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      // ⭐ Pass routeObserver trực tiếp
      navigatorObservers: [routeObserver],
      // ⭐ Register vào GetX sau khi GetMaterialApp xây dựng
      onReady: () {
        Get.put<RouteObserver<ModalRoute<dynamic>>>(
          routeObserver,
          permanent: true,
        );
      },
    );
  }
}
