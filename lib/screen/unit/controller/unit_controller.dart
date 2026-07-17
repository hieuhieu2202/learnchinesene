import 'package:get/get.dart';
import '../../../database/db_helper.dart';
import '../../../models/unit_model.dart';

class UnitController extends GetxController {
  String title = 'Bài học';
  final units = <UnitModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    title = 'Lộ trình ${args?['hskTitle'] ?? 'HSK'}';
    loadUnits((args?['hskLevelId'] as int?) ?? 0);
  }

  Future<void> loadUnits(int hskLevelId) async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final res = await DbHelper.instance.getUnitsByLevel(hskLevelId);
      units.value = res;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
