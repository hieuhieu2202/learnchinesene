import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../features/ai_chat/data/ai_remote_data_source.dart';
import '../features/ai_chat/domain/repositories/ai_repository.dart';
import '../features/ai_chat/domain/usecases/ask_ai.dart';
import '../features/ai_chat/presentation/controllers/ai_chat_controller.dart';
import '../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../features/system/presentation/pages/profile_page.dart';
import '../features/system/presentation/pages/settings_page.dart';
import '../features/system/presentation/pages/splash_page.dart';
import '../features/vocabulary/domain/entities/word.dart';
import '../features/vocabulary/data/datasources/example_local_data_source.dart';
import '../features/vocabulary/data/datasources/progress_local_data_source.dart';
import '../features/vocabulary/data/datasources/user_stats_local_data_source.dart';
import '../features/vocabulary/data/datasources/word_local_data_source.dart';
import '../features/vocabulary/data/repositories/example_repository_impl.dart';
import '../features/vocabulary/data/repositories/progress_repository_impl.dart';
import '../features/vocabulary/data/repositories/user_stats_repository_impl.dart';
import '../features/vocabulary/data/repositories/word_repository_impl.dart';
import '../features/vocabulary/domain/repositories/example_repository.dart';
import '../features/vocabulary/domain/repositories/progress_repository.dart';
import '../features/vocabulary/domain/repositories/word_repository.dart';
import '../features/vocabulary/domain/repositories/user_stats_repository.dart';
import '../features/vocabulary/domain/usecases/add_experience.dart';
import '../features/vocabulary/domain/usecases/get_examples_by_word.dart';
import '../features/vocabulary/domain/usecases/get_progress_for_word.dart';
import '../features/vocabulary/domain/usecases/get_sections.dart';
import '../features/vocabulary/domain/usecases/get_user_stats.dart';
import '../features/vocabulary/domain/usecases/get_word_by_id.dart';
import '../features/vocabulary/domain/usecases/get_words_by_section.dart';
import '../features/vocabulary/domain/usecases/get_words_to_review_today.dart';
import '../features/vocabulary/domain/usecases/update_progress_after_quiz.dart';
import '../features/vocabulary/presentation/controllers/home_controller.dart';
import '../features/vocabulary/presentation/controllers/practice_session_controller.dart';
import '../features/vocabulary/presentation/controllers/review_today_controller.dart';
import '../features/vocabulary/presentation/controllers/section_list_controller.dart';
import '../features/vocabulary/presentation/controllers/word_detail_controller.dart';
import '../features/vocabulary/presentation/controllers/word_list_controller.dart';
import '../features/vocabulary/presentation/pages/home_page.dart';
import '../features/vocabulary/presentation/pages/practice_session_page.dart';
import '../features/vocabulary/presentation/pages/review_today_page.dart';
import '../features/vocabulary/presentation/pages/section_list_page.dart';
import '../features/vocabulary/presentation/pages/word_detail_page.dart';
import '../features/vocabulary/presentation/pages/word_list_page.dart';
import 'app_routes.dart';

class AppBindingsVer1Ne extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<http.Client>(() => http.Client(), fenix: true);

    Get.lazyPut<WordLocalDataSource>(
      () => WordLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<ExampleLocalDataSource>(
      () => ExampleLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<ProgressLocalDataSource>(
      () => ProgressLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<UserStatsLocalDataSource>(
      () => UserStatsLocalDataSourceImpl(),
      fenix: true,
    );

    Get.lazyPut<WordRepository>(
      () => WordRepositoryImpl(
        Get.find<WordLocalDataSource>(),
        Get.find<ProgressLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ExampleRepository>(
      () => ExampleRepositoryImpl(
        Get.find<ExampleLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProgressRepository>(
      () => ProgressRepositoryImpl(
        Get.find<ProgressLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<UserStatsRepository>(
      () => UserStatsRepositoryImpl(
        localDataSource: Get.find<UserStatsLocalDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => GetSectionsVer1Ne(Get.find<WordRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetWordsBySectionVer1Ne(Get.find<WordRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetWordByIdVer1Ne(Get.find<WordRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetExamplesByWordVer1Ne(Get.find<ExampleRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetWordsToReviewTodayVer1Ne(Get.find<ProgressRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetProgressForWordVer1Ne(Get.find<ProgressRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => UpdateProgressAfterQuizVer1Ne(Get.find<ProgressRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => GetUserStatsUseCase(repository: Get.find<UserStatsRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => AddExperienceUseCase(repository: Get.find<UserStatsRepository>()),
      fenix: true,
    );

    Get.lazyPut<AiRepository>(
      () => AiRemoteDataSource(
        client: Get.find<http.Client>(),
        apiKey: AppConfigVer1Ne.geminiApiKey,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => AskAIVer1Ne(Get.find<AiRepository>()),
      fenix: true,
    );
  }
}

class AppPagesVer1Ne {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutesVer1Ne.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutesVer1Ne.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(
          getWordsToReviewToday: Get.find(),
          getSections: Get.find(),
          getWordsBySection: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.sections,
      page: () => const SectionListPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final hskLevel = args['level'] as int? ?? 1;
        Get.put(SectionListController(
          getSections: Get.find(),
          getWordsBySection: Get.find(),
          getProgressForWord: Get.find(),
          initialLevel: hskLevel,
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.wordList,
      page: () => const WordListPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final sectionId = args['sectionId'] as int? ?? 0;
        final sectionTitle = args['sectionTitle'] as String? ?? 'Section';
        Get.put(WordListController(
          sectionId: sectionId,
          sectionTitle: sectionTitle,
          getWordsBySection: Get.find(),
          getProgressForWord: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.wordDetail,
      page: () => const WordDetailPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final wordId = args['wordId'] as int? ?? 0;
        Get.put(WordDetailController(
          wordId: wordId,
          getWordById: Get.find(),
          getExamplesByWord: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.reviewToday,
      page: () => const ReviewTodayPage(),
      binding: BindingsBuilder(() {
        Get.put(ReviewTodayController(
          getWordsToReviewToday: Get.find(),
          getWordById: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.practiceSession,
      page: () => const PracticeSessionPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final words = (args['words'] as List<dynamic>? ?? []).cast<Word>();
        Get.put(PracticeSessionController(
          words: words,
          getExamplesByWord: Get.find(),
          getProgressForWord: Get.find(),
          updateProgressAfterQuiz: Get.find(),
          addExperienceUseCase: Get.find(),
          userStatsRepository: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.aiChat,
      page: () => const AiChatPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        Get.put(AiChatController(
          askAI: Get.find(),
          bootPrompt:
              (args['prompt'] as String?) ?? (args['context'] as String?),
          bootDisplayText: args['displayText'] as String?,
          bootWordContext: args['wordContext'] as String?,
        ));
      }),
    ),
    GetPage(
      name: AppRoutesVer1Ne.settings,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: AppRoutesVer1Ne.profile,
      page: () => const ProfilePage(),
    ),
  ];
}

// Replace old AppPages implementation with alias to the versioned one.
@Deprecated('Use AppPagesVer1Ne')
typedef AppPages = AppPagesVer1Ne;
