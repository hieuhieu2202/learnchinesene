import 'package:get/get.dart';
import '../../../database/db_helper.dart';
import '../../home/home_screen.dart';

class SplashController extends GetxController {
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    start();
  }

  Future<void> start() async {
    error.value = null;
    try {
      await Future.wait([
        DbHelper.instance.database,
        Future<void>.delayed(const Duration(milliseconds: 1500)),
      ]);
      Get.off(() => const HomeScreen());
    } catch (_) {
      error.value = 'Không thể chuẩn bị bài học ngoại tuyến.';
    }
  }
}
