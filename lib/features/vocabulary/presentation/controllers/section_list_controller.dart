import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/get_words_by_section.dart';

class SectionProgress {
  SectionProgress({
    required this.sectionId,
    required this.hskLevel,
    required this.unitTitle,
    required this.totalWords,
    required this.masteredWords,
  });

  final int sectionId;
  final int hskLevel;
  final String unitTitle;
  final int totalWords;
  final int masteredWords;

  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class HskGroup {
  HskGroup({
    required this.level,
    required this.sections,
  });

  final int level;
  final List<SectionProgress> sections;

  String get title =>
      level >= 1 && level <= 4 ? 'HSK $level' : 'Section $level';

  int get totalWords =>
      sections.fold<int>(0, (previousValue, element) => previousValue + element.totalWords);

  int get masteredWords => sections
      .fold<int>(0, (previousValue, element) => previousValue + element.masteredWords);

  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class SectionListController extends GetxController {
  SectionListController({
    required this.getSections,
    required this.getWordsBySection,
  });

  final GetSections getSections;
  final GetWordsBySection getWordsBySection;

  final hskGroups = <HskGroup>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSections();
  }

  Future<void> loadSections() async {
    isLoading.value = true;
    try {
      final sectionIds = await getSections(const NoParams());
      final items = <SectionProgress>[];
      for (final id in sectionIds) {
        final words = await getWordsBySection(id);
        items.add(_buildProgress(id, words));
      }
      hskGroups.assignAll(_buildHskGroups(items));
    } finally {
      isLoading.value = false;
    }
  }

  SectionProgress _buildProgress(int sectionId, List<Word> words) {
    final mastered = words.where((w) => w.mastered).length;
    final rawTitle = words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
    final hskLevel = _parseHskLevel(rawTitle);
    return SectionProgress(
      sectionId: sectionId,
      hskLevel: hskLevel,
      unitTitle: rawTitle,
      totalWords: words.length,
      masteredWords: mastered,
    );
  }

  List<HskGroup> _buildHskGroups(List<SectionProgress> items) {
    final grouped = <int, List<SectionProgress>>{};
    for (final item in items) {
      final level = item.hskLevel;
      grouped.putIfAbsent(level, () => []).add(item);
    }

    final groups = <HskGroup>[];
    for (var level = 1; level <= 4; level++) {
      final sections = grouped[level] ?? <SectionProgress>[];
      sections.sort((a, b) => a.unitTitle.compareTo(b.unitTitle));
      groups.add(HskGroup(level: level, sections: sections));
    }

    final otherLevels = grouped.keys
        .where((level) => level < 1 || level > 4)
        .toList()
      ..sort();
    for (final level in otherLevels) {
      final sections = grouped[level]!;
      sections.sort((a, b) => a.unitTitle.compareTo(b.unitTitle));
      groups.add(HskGroup(level: level, sections: sections));
    }

    return groups;
  }

  int _parseHskLevel(String title) {
    final match = RegExp(r'Section\s*(\d+)').firstMatch(title);
    if (match != null) {
      final value = int.tryParse(match.group(1)!);
      if (value != null) {
        return value.clamp(1, 999).toInt();
      }
    }
    return 1;
  }
}
