import 'dart:io';
import 'package:args/args.dart';
import 'package:architectify/architectify.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information')
    ..addFlag('list-patterns', abbr: 'l', negatable: false, help: 'List all available design patterns')
    ..addOption('pattern', abbr: 'p', help: 'Design pattern to use (1-5 or name)', defaultsTo: '1')
    ..addOption('api-key', abbr: 'k', help: 'OpenAI API key (or set OPENAI_API_KEY env variable)');

  ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print('❌ Error: $e');
    _printUsage(parser);
    return;
  }

  // Show help
  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  // List patterns
  if (results['list-patterns'] as bool) {
    _listPatterns();
    return;
  }

  // Get feature folder path
  if (results.rest.isEmpty) {
    print('❌ Error: Please provide a feature folder path');
    print('');
    _printUsage(parser);
    return;
  }

  final featureFolder = results.rest.first;

  // Get API key
  String? apiKey = results['api-key'] as String?;
  apiKey ??= Platform.environment['OPENAI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ OpenAI API key is required!');
    print('');
    print('💡 Provide it as: architectify <folder> -k <api_key>');
    print('💡 Or set environment variable: OPENAI_API_KEY');
    return;
  }

  // Get selected pattern
  final patternArg = results['pattern'] as String;
  final pattern = _getPattern(patternArg);

  // Show pattern info
  _showPatternInfo(pattern);

  // Run refactor
  final refactor = ArchitectifyRefactor(
    featureDirPath: featureFolder,
    apiKey: apiKey,
    pattern: pattern,
  );
  await refactor.run();
}

void _printUsage(ArgParser parser) {
  print('''
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║     █████╗ ██████╗  ██████╗██╗  ██╗██╗████████╗███████╗ ██████╗████████╗██╗   ║
║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██║╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██║   ║
║    ███████║██████╔╝██║     ███████║██║   ██║   █████╗  ██║        ██║   ██║   ║
║    ██╔══██║██╔══██╗██║     ██╔══██║██║   ██║   ██╔══╝  ██║        ██║   ╚═╝   ║
║    ██║  ██║██║  ██║╚██████╗██║  ██║██║   ██║   ███████╗╚██████╗   ██║   ██╗   ║
║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝   ╚═╝   ║
║                                                                               ║
║              🏗️  AI-Powered Flutter Architecture Refactoring Tool              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

USAGE:
  architectify <feature_folder_path> [options]

OPTIONS:
${parser.usage}

EXAMPLES:
  # Use Clean Architecture (default)
  architectify ./lib/features/auth -k sk-xxx

  # Use MVVM pattern
  architectify ./lib/features/auth -p 2 -k sk-xxx

  # Use pattern by name
  architectify ./lib/features/auth -p mvvm -k sk-xxx

  # List all patterns
  architectify -l

ENVIRONMENT:
  OPENAI_API_KEY    Your OpenAI API key (alternative to -k option)
''');
}

void _listPatterns() {
  print('''
╔═══════════════════════════════════════════════════════════════════════════════╗
║                        📐 Available Design Patterns                           ║
╚═══════════════════════════════════════════════════════════════════════════════╝
''');

  final patterns = DesignPatterns.all;
  for (var i = 0; i < patterns.length; i++) {
    final pattern = patterns[i];
    print('┌───────────────────────────────────────────────────────────────────────────────┐');
    print('│ ${i + 1}. ${pattern.name.padRight(71)}│');
    print('├───────────────────────────────────────────────────────────────────────────────┤');
    
    // Print description (handle multiline)
    final descLines = pattern.description.trim().split('\n');
    for (final line in descLines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty) {
        print('│ ${trimmedLine.padRight(77)}│');
      }
    }
    
    print('│${''.padRight(79)}│');
    print('│ ${'✅ Benefits:'.padRight(77)}│');
    for (final benefit in pattern.benefits) {
      print('│   ${benefit.padRight(75)}│');
    }
    print('└───────────────────────────────────────────────────────────────────────────────┘');
    print('');
  }

  print('Use: architectify <folder> -p <number or name> -k <api_key>');
}

DesignPattern _getPattern(String arg) {
  // Try as number first
  final index = int.tryParse(arg);
  if (index != null) {
    return DesignPatterns.getByIndex(index);
  }
  
  // Try as name
  final pattern = DesignPatterns.getByName(arg);
  if (pattern != null) {
    return pattern;
  }
  
  // Default to Clean Architecture
  print('⚠️ Unknown pattern "$arg", using Clean Architecture');
  return DesignPatterns.cleanArchitecture;
}

void _showPatternInfo(DesignPattern pattern) {
  print('');
  print('╔═══════════════════════════════════════════════════════════════════════════════╗');
  print('║ 🏗️  Selected Pattern: ${pattern.name.padRight(54)}║');
  print('╚═══════════════════════════════════════════════════════════════════════════════╝');
  print('');
  print('📝 Description:');
  for (final line in pattern.description.trim().split('\n')) {
    if (line.trim().isNotEmpty) {
      print('   ${line.trim()}');
    }
  }
  print('');
  print('✅ Benefits:');
  for (final benefit in pattern.benefits) {
    print('   $benefit');
  }
  print('');
  print('📁 Folder Structure:');
  for (final folder in pattern.folderStructure.take(6)) {
    print('   └── $folder');
  }
  if (pattern.folderStructure.length > 6) {
    print('   └── ... and ${pattern.folderStructure.length - 6} more');
  }
}
