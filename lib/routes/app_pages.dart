import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../features/ai_chat/data/ai_remote_data_source.dart';
import '../features/ai_chat/domain/usecases/ask_ai.dart';
import '../features/ai_chat/presentation/controllers/ai_chat_controller.dart';
import '../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../features/vocabulary/domain/entities/word.dart';
import '../features/vocabulary/data/datasources/example_local_data_source.dart';
import '../features/vocabulary/data/datasources/progress_local_data_source.dart';
import '../features/vocabulary/data/datasources/word_local_data_source.dart';
import '../features/vocabulary/data/repositories/example_repository_impl.dart';
import '../features/vocabulary/data/repositories/progress_repository_impl.dart';
import '../features/vocabulary/data/repositories/word_repository_impl.dart';
import '../features/vocabulary/domain/usecases/get_examples_by_word.dart';
import '../features/vocabulary/domain/usecases/get_progress_for_word.dart';
import '../features/vocabulary/domain/usecases/get_sections.dart';
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

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<http.Client>(() => http.Client(), fenix: true);

    Get.lazyPut<WordLocalDataSource>(() => WordLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<ExampleLocalDataSource>(() => ExampleLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<ProgressLocalDataSource>(() => ProgressLocalDataSourceImpl(), fenix: true);

    Get.lazyPut(() => WordRepositoryImpl(Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => ExampleRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut(() => ProgressRepositoryImpl(Get.find()), fenix: true);

    Get.lazyPut(() => GetSections(Get.find()), fenix: true);
    Get.lazyPut(() => GetWordsBySection(Get.find()), fenix: true);
    Get.lazyPut(() => GetWordById(Get.find()), fenix: true);
    Get.lazyPut(() => GetExamplesByWord(Get.find()), fenix: true);
    Get.lazyPut(() => GetWordsToReviewToday(Get.find()), fenix: true);
    Get.lazyPut(() => GetProgressForWord(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateProgressAfterQuiz(Get.find()), fenix: true);

    Get.lazyPut<AiRemoteDataSource>(() => AiRemoteDataSource(
          client: Get.find<http.Client>(),
          apiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
        ),
        fenix: true);
    Get.lazyPut(() => AskAI(Get.find<AiRemoteDataSource>()), fenix: true);
  }
}

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(
          getWordsToReviewToday: Get.find(),
          getSections: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.sections,
      page: () => const SectionListPage(),
      binding: BindingsBuilder(() {
        Get.put(SectionListController(
          getSections: Get.find(),
          getWordsBySection: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.wordList,
      page: () => const WordListPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final sectionId = args['sectionId'] as int? ?? 0;
        final sectionTitle = args['sectionTitle'] as String? ?? 'Section';
        Get.put(WordListController(
          sectionId: sectionId,
          sectionTitle: sectionTitle,
          getWordsBySection: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.wordDetail,
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
      name: AppRoutes.reviewToday,
      page: () => const ReviewTodayPage(),
      binding: BindingsBuilder(() {
        Get.put(ReviewTodayController(
          getWordsToReviewToday: Get.find(),
          getWordById: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.practiceSession,
      page: () => const PracticeSessionPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final words = (args['words'] as List<dynamic>? ?? []).cast<Word>();
        final mode = args['mode'] as PracticeMode? ?? PracticeMode.flashcard;
        Get.put(PracticeSessionController(
          words: words,
          mode: mode,
          getProgressForWord: Get.find(),
          updateProgressAfterQuiz: Get.find(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AiChatPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        Get.put(AiChatController(
          askAI: Get.find(),
          initialContext: args['context'] as String?,
        ));
      }),
    ),
  ];
}
