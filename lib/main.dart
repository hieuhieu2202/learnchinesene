import 'package:flutter/material.dart';
import 'app.dart';
import 'di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDI();
  runApp(const ChineseMasterApp());
}
