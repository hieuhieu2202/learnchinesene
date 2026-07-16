import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart' show LearnChineseApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LearnChineseApp());
}
