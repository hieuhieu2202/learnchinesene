import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'database/db_helper.dart';
import 'screens/home_screen.dart';
import 'screens/hsk_screen.dart';
import 'screens/learning_overview_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/review_screen.dart';
import 'screens/speaking_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/unit_screen.dart';
import 'screens/word_detail_screen.dart';
import 'screens/word_list_screen.dart';

class ChineseMasterApp extends StatelessWidget {
  const ChineseMasterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Học tiếng Trung',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: SplashScreen(
            databaseReady: DbHelper.instance.database.then((_) {})),
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          HskScreen.routeName: (_) => const HskScreen(),
          UnitScreen.routeName: (_) => const UnitScreen(),
          LearningOverviewScreen.routeName: (_) =>
              const LearningOverviewScreen(),
          WordListScreen.routeName: (_) => const WordListScreen(),
          WordDetailScreen.routeName: (_) => const WordDetailScreen(),
          QuizScreen.routeName: (_) => const QuizScreen(),
          SpeakingScreen.routeName: (_) => const SpeakingScreen(),
          ReviewScreen.routeName: (_) => const ReviewScreen(),
          StatsScreen.routeName: (_) => const StatsScreen(),
        },
      );
}
