// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learnchinese/main.dart';
import 'package:learnchinese/services/speech_service.dart';

void main() {
  testWidgets('App renders branded startup experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnChineseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Học tiếng Trung'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  test('Speaking similarity handles exact and different phrases', () {
    final service = SpeechService();
    expect(service.similarityScore('你好', '你好'), 100);
    expect(service.similarityScore('你好', '再见'), lessThan(80));
  });
}
