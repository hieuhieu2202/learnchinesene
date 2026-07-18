import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'screen/home/controller/home_controller.dart';
import 'screen/splash/controller/splash_controller.dart';
import 'services/gemini_service.dart';
import 'services/history_service.dart';

void initDI() {
  Get.lazyPut(() => http.Client(), fenix: true);
  Get.lazyPut(() => GeminiService(client: Get.find<http.Client>()),
      fenix: true);
  Get.lazyPut(() => HistoryService(), fenix: true);
  Get.lazyPut(() => SplashController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
}
