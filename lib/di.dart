import 'package:get/get.dart';

import 'screen/home/controller/home_controller.dart';
import 'screen/splash/controller/splash_controller.dart';

void initDI() {
  Get.lazyPut(() => SplashController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
}
