import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/unit_model.dart';
import '../widgets/empty_state_widget.dart';
import '../core/responsive/responsive_layout.dart';
import 'learning_overview_screen.dart';

class UnitScreen extends StatefulWidget {
  static const routeName = '/units';
  const UnitScreen({super.key});
  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  Future<List<UnitModel>>? future;
  String title = 'Bài học';
  bool loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final a =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    title = 'Lộ trình ${a?['hskTitle'] ?? 'HSK'}';
    future = DbHelper.instance.getUnitsByLevel((a?['hskLevelId'] as int?) ?? 0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: FutureBuilder<List<UnitModel>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snap.hasError)
          return const EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tải bài học',
            message: 'Không thể đọc các bài học từ dữ liệu ngoại tuyến.',
          );
        final units = snap.data ?? [];
        if (units.isEmpty)
          return const EmptyStateWidget(
            icon: Icons.route_rounded,
            title: 'Chưa có bài học',
            message: 'Cấp độ này chưa có nội dung bài học.',
          );
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.horizontalPadding(context),
                vertical: 24,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 450,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 96,
              ),
              itemCount: units.length,
              itemBuilder: (context, i) => _UnitTile(unit: units[i], number: i + 1),
            ),
          ),
        );
      },
    ),
  );
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit, required this.number});
  final UnitModel unit;
  final int number;
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, int>>(
    future: DbHelper.instance.getUnitMetrics(unit.id),
    builder: (context, snap) {
      final m = snap.data ?? const {'words': 0, 'learned': 0};
      final words = m['words'] ?? 0;
      final learned = m['learned'] ?? 0;
      final p = words == 0 ? 0.0 : learned / words;
      final status = p >= 1
          ? 'Đã thành thạo'
          : p > 0
          ? 'Đang học'
          : 'Mới';
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.pushNamed(
            context,
            LearningOverviewScreen.routeName,
            arguments: {'unitId': unit.id, 'unitTitle': unit.title},
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$words từ  •  $status',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 9),
                      LinearProgressIndicator(
                        value: p,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(p * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
