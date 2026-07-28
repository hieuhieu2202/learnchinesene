import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'screen/home/controller/home_controller.dart';
import 'screen/splash/controller/splash_controller.dart';
import 'services/gemini_service.dart';
import 'services/history_service.dart';
import 'core/services/iap_service.dart';
import 'features/subscription/controller/subscription_controller.dart';

void initDI() {
  Get.lazyPut(() => http.Client(), fenix: true);
  Get.lazyPut(() => GeminiService(client: Get.find<http.Client>()),
      fenix: true);
  Get.lazyPut(() => HistoryService(), fenix: true);
  Get.lazyPut(() => SplashController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => IAPService(), fenix: true);
  Get.lazyPut(() => SubscriptionController(Get.find<IAPService>()), fenix: true);
}
