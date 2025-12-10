import 'dart:io';
import 'package:architectify/architectify.dart';
import 'package:test/test.dart';

void main() {
  group('DesignPatterns', () {
    test('has 5 available patterns', () {
      expect(DesignPatterns.all.length, equals(5));
    });

    test('getByIndex returns correct pattern', () {
      expect(DesignPatterns.getByIndex(1).name, equals('Clean Architecture'));
      expect(DesignPatterns.getByIndex(2).name, equals('MVVM (Model-View-ViewModel)'));
      expect(DesignPatterns.getByIndex(3).name, equals('MVC (Model-View-Controller)'));
      expect(DesignPatterns.getByIndex(4).name, equals('BLoC Pattern'));
      expect(DesignPatterns.getByIndex(5).name, equals('Feature-First'));
    });

    test('getByIndex returns default for invalid index', () {
      expect(DesignPatterns.getByIndex(0).name, equals('Clean Architecture'));
      expect(DesignPatterns.getByIndex(99).name, equals('Clean Architecture'));
    });

    test('getByName finds patterns correctly', () {
      expect(DesignPatterns.getByName('clean')?.name, equals('Clean Architecture'));
      expect(DesignPatterns.getByName('mvvm')?.name, equals('MVVM (Model-View-ViewModel)'));
      expect(DesignPatterns.getByName('bloc')?.name, equals('BLoC Pattern'));
    });

    test('getByName returns null for unknown pattern', () {
      expect(DesignPatterns.getByName('unknown'), isNull);
    });

    test('each pattern has required fields', () {
      for (final pattern in DesignPatterns.all) {
        expect(pattern.name, isNotEmpty);
        expect(pattern.description, isNotEmpty);
        expect(pattern.benefits, isNotEmpty);
        expect(pattern.folderStructure, isNotEmpty);
        expect(pattern.aiPromptTemplate, isNotEmpty);
      }
    });
  });

  group('DesignPattern', () {
    test('Clean Architecture has correct folder structure', () {
      final pattern = DesignPatterns.cleanArchitecture;
      expect(pattern.folderStructure, contains('data/models'));
      expect(pattern.folderStructure, contains('domain/entities'));
      expect(pattern.folderStructure, contains('domain/use_cases'));
      expect(pattern.folderStructure, contains('presentation/view'));
    });

    test('MVVM has correct folder structure', () {
      final pattern = DesignPatterns.mvvm;
      expect(pattern.folderStructure, contains('models'));
      expect(pattern.folderStructure, contains('views'));
      expect(pattern.folderStructure, contains('viewmodels'));
    });
  });

  group('ConfigService', () {
    // Use a temp directory for testing to avoid affecting real config
    late String originalHome;
    late Directory tempDir;

    setUp(() {
      // Create a temp directory for testing
      tempDir = Directory.systemTemp.createTempSync('architectify_test_');
      originalHome = Platform.isWindows
          ? Platform.environment['USERPROFILE'] ?? ''
          : Platform.environment['HOME'] ?? '';
    });

    tearDown(() {
      // Clean up temp directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('isValidApiKeyFormat validates correctly', () {
      // Valid format
      expect(ConfigService.isValidApiKeyFormat('sk-1234567890abcdefghijklmn'), isTrue);
      expect(ConfigService.isValidApiKeyFormat('sk-proj-longapikeywithmanycharacters'), isTrue);

      // Invalid format
      expect(ConfigService.isValidApiKeyFormat(''), isFalse);
      expect(ConfigService.isValidApiKeyFormat('api-key'), isFalse);
      expect(ConfigService.isValidApiKeyFormat('sk-short'), isFalse);
      expect(ConfigService.isValidApiKeyFormat('invalid-key-format'), isFalse);
    });

    test('configDir returns correct path format', () {
      final configDir = ConfigService.configDir;
      expect(configDir, isNotEmpty);
      expect(configDir, contains('.architectify'));
    });

    test('configFilePath includes config.json', () {
      final configFilePath = ConfigService.configFilePath;
      expect(configFilePath, contains('config.json'));
      expect(configFilePath, contains('.architectify'));
    });
  });

  group('ArchitectifyRefactor', () {
    test('constructor initializes with required parameters', () {
      final refactor = ArchitectifyRefactor(
        featureDirPath: './test_feature',
        apiKey: 'sk-test-api-key-12345678901234',
        pattern: DesignPatterns.cleanArchitecture,
      );

      expect(refactor.featureDirPath, equals('./test_feature'));
      expect(refactor.apiKey, equals('sk-test-api-key-12345678901234'));
      expect(refactor.pattern.name, equals('Clean Architecture'));
      expect(refactor.userStory, isNull);
    });

    test('constructor accepts optional userStory', () {
      final refactor = ArchitectifyRefactor(
        featureDirPath: './test_feature',
        apiKey: 'sk-test-api-key-12345678901234',
        pattern: DesignPatterns.mvvm,
        userStory: 'As a user, I want to login with email',
      );

      expect(refactor.userStory, equals('As a user, I want to login with email'));
      expect(refactor.pattern.name, equals('MVVM (Model-View-ViewModel)'));
    });

    test('works with all design patterns', () {
      for (final pattern in DesignPatterns.all) {
        final refactor = ArchitectifyRefactor(
          featureDirPath: './test_feature',
          apiKey: 'sk-test-api-key-12345678901234',
          pattern: pattern,
        );

        expect(refactor.pattern, equals(pattern));
      }
    });

    test('featureDir is initialized from featureDirPath', () {
      final refactor = ArchitectifyRefactor(
        featureDirPath: './my_feature',
        apiKey: 'sk-test-api-key-12345678901234',
        pattern: DesignPatterns.bloc,
      );

      expect(refactor.featureDir.path, contains('my_feature'));
    });
  });

  group('Integration', () {
    test('all exports are accessible from package', () {
      // These should not throw - verifying exports work
      expect(DesignPatterns, isNotNull);
      expect(DesignPatterns.all, isNotEmpty);
      expect(ConfigService, isNotNull);
    });
  });
}
