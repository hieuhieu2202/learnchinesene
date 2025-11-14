import '../../domain/entities/example_sentence.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_local_data_source.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  ExampleRepositoryImpl(this.localDataSource);

  final ExampleLocalDataSource localDataSource;

  @override
  Future<List<ExampleSentence>> getExamplesByWord(int wordId) {
    return localDataSource.getExamplesByWord(wordId);
  }
}
