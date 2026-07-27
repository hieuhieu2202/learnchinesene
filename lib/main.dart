import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dependecy_injection.dart' as di;
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const HeroChineseTypingAppVer1Ne());
}

class HeroChineseTypingAppVer1Ne extends StatelessWidget {
  const HeroChineseTypingAppVer1Ne({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ Tạo RouteObserver cục bộ (không dùng Get.find)
    final routeObserver = RouteObserver<ModalRoute<dynamic>>();

    return GetMaterialApp(
      title: 'Hero Chinese Typing',
      theme: AppThemeVer1Ne.light(),
      initialRoute: AppRoutesVer1Ne.splash,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindingsVer1Ne(),
      getPages: AppPages.pages,
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
