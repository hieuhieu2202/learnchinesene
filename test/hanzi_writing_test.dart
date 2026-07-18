import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:chinese_master/features/hanzi_writing/services/svg_stroke_parser.dart';
import 'package:chinese_master/features/hanzi_writing/services/stroke_sampler.dart';
import 'package:chinese_master/features/hanzi_writing/services/stroke_validator.dart';
import 'package:chinese_master/features/hanzi_writing/models/hanzi_practice_config.dart';
import 'package:chinese_master/features/hanzi_writing/painters/hanzi_writing_painter.dart';

class MockCanvas extends Fake implements Canvas {
  final List<Paint> paintsUsed = [];
  final List<Path> pathsUsed = [];

  @override
  void save() {}
  @override
  void translate(double dx, double dy) {}
  @override
  void scale(double sx, [double? sy]) {}
  @override
  void restore() {}

  @override
  void drawPath(Path path, Paint paint) {
    paintsUsed.add(paint);
    pathsUsed.add(path);
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    paintsUsed.add(paint);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    paintsUsed.add(paint);
  }
}

void main() {
  group('SvgStrokeParser Tests', () {
    test('Dữ liệu strokePathData null/rỗng', () {
      final paths = SvgStrokeParser.parseStrokePaths('');
      expect(paths, isEmpty);
    });

    test('Tách nét bằng ký tự |', () {
      final paths =
          SvgStrokeParser.parseStrokePaths('M 10,10 L 20,20|M 20,20 L 30,30');
      expect(paths.length, 2);
      expect(paths[0], 'M 10,10 L 20,20');
      expect(paths[1], 'M 20,20 L 30,30');
    });

    test('Parse SVG Path hợp lệ', () {
      final path = SvgStrokeParser.parseSvgPath('M 10,10 L 20,20');
      expect(path, isNotNull);
    });

    test('Xử lý SVG Path lỗi', () {
      final path = SvgStrokeParser.parseSvgPath('INVALID SVG DATA');
      expect(path, isNull);
    });
  });

  group('StrokeSampler & StrokeValidator Tests', () {
    test('StrokeSampler resamples to correct point count', () {
      final points = [
        const Offset(0, 0),
        const Offset(10, 10),
        const Offset(20, 20)
      ];
      final resampled = StrokeSampler.resample(points, 70);
      expect(resampled.length, 70);
    });

    test('Nét gần đúng được chấp nhận và nét sai chiều bị từ chối', () {
      final refPath = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 100);

      final userCorrectPoints =
          List.generate(10, (i) => Offset(i * 10.0, i * 10.0));
      final correctResult = StrokeValidator.validate(
        userPoints: userCorrectPoints,
        refPath: refPath,
      );
      expect(correctResult.isValid, isTrue);

      final userReversePoints =
          List.generate(10, (i) => Offset(100.0 - i * 10.0, 100.0 - i * 10.0));
      final reverseResult = StrokeValidator.validate(
        userPoints: userReversePoints,
        refPath: refPath,
      );
      expect(reverseResult.isValid, isFalse);
      expect(reverseResult.errorMessage, 'Sai chiều viết.');

      final wrongStartPoints =
          List.generate(10, (i) => Offset(50.0 + i * 10.0, 50.0 + i * 10.0));
      final wrongStartResult = StrokeValidator.validate(
        userPoints: wrongStartPoints,
        refPath: refPath,
      );
      expect(wrongStartResult.isValid, isFalse);
      expect(wrongStartResult.errorMessage, 'Điểm bắt đầu chưa đúng.');
    });
  });

  group('Hanzi Practice 10-Round Config Tests', () {
    test('calculatePrefilledStrokeCount clamp and values', () {
      // 1 stroke character
      expect(calculatePrefilledStrokeCount(strokeCount: 1, ratio: 0.25), 0);
      expect(calculatePrefilledStrokeCount(strokeCount: 1, ratio: 0.50), 0);

      // 4 stroke character (e.g. 水)
      // 4 * 0.25 = 1.0 -> clamp(1, 3) = 1
      expect(calculatePrefilledStrokeCount(strokeCount: 4, ratio: 0.25), 1);
      // 4 * 0.50 = 2.0 -> clamp(1, 3) = 2
      expect(calculatePrefilledStrokeCount(strokeCount: 4, ratio: 0.50), 2);

      // 10 stroke character
      // 10 * 0.25 = 2.5 -> 2 -> clamp(1, 9) = 2
      expect(calculatePrefilledStrokeCount(strokeCount: 10, ratio: 0.25), 2);
      // 10 * 0.50 = 5.0 -> 5 -> clamp(1, 9) = 5
      expect(calculatePrefilledStrokeCount(strokeCount: 10, ratio: 0.50), 5);
    });

    test('generateRoundConfigs outputs 10 progressive rounds', () {
      final configs = generateRoundConfigs(4);
      expect(configs.length, 10);

      // Round 1
      expect(configs[0].roundNumber, 1);
      expect(configs[0].mode, HanziPracticeMode.guidedTrace);
      expect(configs[0].prefilledStrokeCount, 0);
      expect(configs[0].showCurrentStroke, isTrue);
      expect(configs[0].showStartPoint, isTrue);
      expect(configs[0].showDirectionArrow, isTrue);

      // Round 2
      expect(configs[1].roundNumber, 2);
      expect(configs[1].mode, HanziPracticeMode.guidedTrace);
      expect(configs[1].showDirectionArrow, isFalse);

      // Round 3
      expect(configs[2].roundNumber, 3);
      expect(configs[2].mode, HanziPracticeMode.completeRemaining);
      expect(configs[2].prefilledStrokeCount, 1);

      // Round 4
      expect(configs[3].roundNumber, 4);
      expect(configs[3].mode, HanziPracticeMode.completeRemaining);
      expect(configs[3].prefilledStrokeCount, 1); // 4 * 0.25 clamped

      // Round 5
      expect(configs[4].roundNumber, 5);
      expect(configs[4].mode, HanziPracticeMode.completeRemaining);
      expect(configs[4].prefilledStrokeCount, 2); // 4 * 0.50 clamped

      // Round 6
      expect(configs[5].roundNumber, 6);
      expect(configs[5].mode, HanziPracticeMode.faintCharacter);
      expect(configs[5].prefilledStrokeCount, 0);
      expect(configs[5].showCurrentStroke, isFalse);

      // Round 8
      expect(configs[7].roundNumber, 8);
      expect(configs[7].mode, HanziPracticeMode.startPointOnly);
      expect(configs[7].guideOpacity, 0.0);
      expect(configs[7].showStartPoint, isTrue);

      // Round 9 & 10
      expect(configs[8].mode, HanziPracticeMode.fromScratch);
      expect(configs[8].guideOpacity, 0.0);
      expect(configs[8].showCurrentStroke, isFalse);
      expect(configs[8].showStartPoint, isFalse);

      expect(configs[9].mode, HanziPracticeMode.fromScratch);
      expect(configs[9].guideOpacity, 0.0);
    });
  });

  group('HanziWritingPainter PaintingStyle Tests', () {
    test(
        'Painter uses PaintingStyle.stroke for drawing templates and completed strokes',
        () {
      final path1 = Path()
        ..moveTo(10, 10)
        ..lineTo(20, 20);
      final path2 = Path()
        ..moveTo(20, 20)
        ..lineTo(30, 30);

      final painter = HanziWritingPainter(
        strokePaths: [path1, path2],
        completedIndexes: {0},
        currentIndex: 1,
        viewBoxWidth: 110,
        viewBoxHeight: 110,
        guideOpacity: 0.35,
        showCurrentStroke: true,
        showStartPoint: true,
        showDirectionArrow: true,
      );

      final mockCanvas = MockCanvas();
      painter.paint(mockCanvas, const Size(110, 110));

      expect(mockCanvas.paintsUsed, isNotEmpty);

      // Filter out filled paints (like the start point dot which can use fill style)
      // Standard line paths MUST use style PaintingStyle.stroke
      final strokePaints = mockCanvas.paintsUsed
          .where((p) => p.style == PaintingStyle.stroke)
          .toList();
      expect(strokePaints, isNotEmpty);

      // None of the line drawing paints should use fill style
      for (final paint in strokePaints) {
        expect(paint.style, PaintingStyle.stroke);
      }
    });
  });

  group('Database Integration Tests via sqlite3', () {
    test('Đọc danh sách chữ và chi tiết nét vẽ', () {
      final dbFile = File('assets/database/chinese_v2_sheet1_only.db');
      expect(dbFile.existsSync(), isTrue);

      final db = sqlite3.open(dbFile.path);

      final listResult = db.select('''
        SELECT c.id, c.character, c.stroke_count, c.stroke_width, c.stroke_height,
               COALESCE(w1.pinyin, w2.pinyin) as pinyin,
               COALESCE(w1.meaning_vi, w2.meaning_vi) as meaning,
               COALESCE(w1.hsk_level_id, w2.hsk_level_id) as hsk_level_id,
               '' as stroke_paths
        FROM characters c
        LEFT JOIN words w1 ON w1.word = c.character
        LEFT JOIN words w2 ON w2.id = (
            SELECT id FROM words 
            WHERE main_character_id = c.id 
            LIMIT 1
        )
        GROUP BY c.id
      ''');
      expect(listResult, isNotEmpty);

      final firstRow = listResult.first;
      expect(firstRow['character'], isNotNull);
      expect(firstRow['stroke_count'], isNotNull);

      final detailResult = db.select('''
        SELECT c.id, c.character, c.stroke_count, c.stroke_width, c.stroke_height, c.stroke_paths,
               COALESCE(w1.pinyin, w2.pinyin) as pinyin,
               COALESCE(w1.meaning_vi, w2.meaning_vi) as meaning,
               COALESCE(w1.hsk_level_id, w2.hsk_level_id) as hsk_level_id
        FROM characters c
        LEFT JOIN words w1 ON w1.word = c.character
        LEFT JOIN words w2 ON w2.id = (
            SELECT id FROM words 
            WHERE main_character_id = c.id 
            LIMIT 1
        )
        WHERE c.id = ?
      ''', [firstRow['id']]);
      expect(detailResult, isNotEmpty);
      expect(detailResult.first['stroke_paths'], isNotNull);

      db.dispose();
    });
  });
}
