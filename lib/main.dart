import 'package:flutter/material.dart';

import 'app.dart';
import 'core/backend/supabase_bootstrap.dart';
import 'di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.initialize();
  initDI();
  runApp(const ChineseMasterApp());
}
