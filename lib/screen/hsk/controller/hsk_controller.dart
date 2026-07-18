import 'package:get/get.dart';
import '../../../database/db_helper.dart';
import '../../../models/hsk_level.dart';

class HskController extends GetxController {
  final levels = <HskLevel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLevels();
  }

  Future<void> loadLevels() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final res = await DbHelper.instance.getHskLevels();
      levels.value = res;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
