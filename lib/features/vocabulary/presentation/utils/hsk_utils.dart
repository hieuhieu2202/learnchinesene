int parseHskLevel({
  required int sectionId,
  required String sectionTitle,
}) {
  final normalizedTitle = sectionTitle.toLowerCase();
  final hskMatch = RegExp(r'hsk\s*(\d+)').firstMatch(normalizedTitle);
  if (hskMatch != null) {
    final value = int.tryParse(hskMatch.group(1)!);
    if (value != null && value > 0) {
      return value.clamp(1, 6).toInt();
    }
  }

  final sectionMatch = RegExp(r'section\s*(\d+)').firstMatch(normalizedTitle);
  if (sectionMatch != null) {
    final value = int.tryParse(sectionMatch.group(1)!);
    if (value != null) {
      return _mapSectionNumberToLevel(value);
    }
  }

  return _mapSectionNumberToLevel(sectionId);
}

int _mapSectionNumberToLevel(int value) {
  if (value <= 0) {
    return 1;
  }
  if (value <= 4) {
    return value;
  }

  // Group higher section numbers into the closest HSK tier while capping at HSK 6.
  final inferred = ((value - 1) ~/ 10) + 1;
  return inferred.clamp(1, 6).toInt();
}
