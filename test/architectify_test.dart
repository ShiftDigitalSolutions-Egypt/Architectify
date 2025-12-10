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
}
