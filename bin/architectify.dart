import 'dart:io';
import 'package:args/args.dart';
import 'package:architectify/architectify.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information')
    ..addFlag('list-patterns', abbr: 'l', negatable: false, help: 'List all available design patterns')
    ..addFlag('reset-key', negatable: false, help: 'Clear saved API key and all configuration')
    ..addOption('pattern', abbr: 'p', help: 'Design pattern to use (1-5 or name)', defaultsTo: '1')
    ..addOption('api-key', abbr: 'k', help: 'OpenAI API key (overrides saved key)')
    ..addOption('story', abbr: 's', help: 'User story text to generate feature from')
    ..addOption('model', abbr: 'm', help: 'AI Model to use', defaultsTo: 'gpt-4o')
    ..addFlag('scan', negatable: false, help: 'Scan project for security vulnerabilities');

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

  // Reset API key
  if (results['reset-key'] as bool) {
    await _resetApiKey();
    return;
  }

  // Get API key (priority: CLI arg > saved config > env var > prompt)
  String? apiKey = await _getOrPromptApiKey(results['api-key'] as String?);

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ OpenAI API key is required!');
    print('');
    print('💡 Run the tool again to set up your API key');
    return;
  }

  // Get selected model
  final model = results['model'] as String;

  // Handle Security Scan
  if (results['scan'] as bool) {
    // For scan, we need a target folder.
    if (results.rest.isEmpty) {
       print('❌ Error: Please provide a folder to scan');
       print('');
       _printUsage(parser);
       return;
    }
    
    final targetDir = Directory(results.rest.first);
    final scanner = SecurityScanner(apiKey: apiKey, model: model);
    final report = await scanner.scan(targetDir);

    if (report != null) {
      // Prompt for auto-fix
      print('');
      stdout.write('🔧 Do you want to attempt to automatically fix these issues with AI? (y/N): ');
      final fixConfirm = stdin.readLineSync()?.trim().toLowerCase();
      
      if (fixConfirm == 'y' || fixConfirm == 'yes') {
        await scanner.fixIssues(targetDir);

        // Re-scan
        print('');
        print('🔄 Re-scanning to verify fixes...');
        final newReport = await scanner.scan(targetDir);

        if (newReport != null) {
          await scanner.compareReports(report, newReport);
        }
      }
    }
    return;
  }

  // Get feature folder path
  if (results.rest.isEmpty) {
    // If user story is provided without folder, we can generate a new feature
    final story = results['story'] as String?;
    if (story == null || story.isEmpty) {
      print('❌ Error: Please provide a feature folder path');
      print('');
      _printUsage(parser);
      return;
    }
    // For story-only mode, prompt for feature folder
    print('❌ Error: Please also provide a feature folder path');
    print('');
    print('💡 Usage: architectify <folder> -s "Your user story here"');
    return;
  }

  final featureFolder = results.rest.first;
  final userStory = results['story'] as String?;

  // Get selected pattern
  final patternArg = results['pattern'] as String;
  final pattern = _getPattern(patternArg);

  // Show pattern info
  _showPatternInfo(pattern);

  // Show user story if provided
  if (userStory != null && userStory.isNotEmpty) {
    print('');
    print('📖 User Story:');
    print('   ${userStory.split('\n').join('\n   ')}');
  }

  // Run refactor
  final refactor = ArchitectifyRefactor(
    featureDirPath: featureFolder,
    apiKey: apiKey,
    pattern: pattern,
    userStory: userStory,
    model: model,
  );
  await refactor.run();
}

/// Get API key from various sources or prompt user
Future<String?> _getOrPromptApiKey(String? cliApiKey) async {
  // 1. CLI argument takes priority
  if (cliApiKey != null && cliApiKey.isNotEmpty) {
    return cliApiKey;
  }

  // 2. Check saved config
  final savedKey = ConfigService.getApiKey();
  if (savedKey != null && savedKey.isNotEmpty) {
    print('🔑 Using saved API key from ~/.architectify/config.json');
    return savedKey;
  }

  // 3. Check environment variable
  final envKey = Platform.environment['OPENAI_API_KEY'];
  if (envKey != null && envKey.isNotEmpty) {
    print('🔑 Using API key from OPENAI_API_KEY environment variable');
    return envKey;
  }

  // 4. First-time setup - prompt user
  return await _promptForApiKey();
}

/// Interactive first-time API key setup
Future<String?> _promptForApiKey() async {
  print('');
  print('╔═══════════════════════════════════════════════════════════════════════════════╗');
  print('║                    🏗️  Welcome to Architectify!                               ║');
  print('╚═══════════════════════════════════════════════════════════════════════════════╝');
  print('');
  print('🔑 First-time setup detected!');
  print('');
  print('   Architectify uses OpenAI GPT-4o to intelligently refactor your code.');
  print('   You can get an API key from: https://platform.openai.com/api-keys');
  print('');
  stdout.write('   Please enter your OpenAI API key: ');

  // Read API key from stdin
  final apiKey = stdin.readLineSync()?.trim();

  if (apiKey == null || apiKey.isEmpty) {
    print('');
    print('❌ No API key provided.');
    return null;
  }

  // Validate format
  if (!ConfigService.isValidApiKeyFormat(apiKey)) {
    print('');
    print('⚠️  Warning: API key format looks unusual (should start with "sk-")');
    stdout.write('   Are you sure you want to continue? (y/N): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase();
    if (confirm != 'y' && confirm != 'yes') {
      print('');
      print('❌ Setup cancelled.');
      return null;
    }
  }

  // Save the API key
  try {
    await ConfigService.saveApiKey(apiKey);
    print('');
    print('✅ API key saved to ~/.architectify/config.json');
    print('   (Use --reset-key to change it later)');
    print('');
    return apiKey;
  } catch (e) {
    print('');
    print('⚠️  Could not save API key: $e');
    print('   Using key for this session only.');
    return apiKey;
  }
}

/// Reset/clear the saved API key
Future<void> _resetApiKey() async {
  print('');
  print('🗑️  Clearing saved configuration...');
  
  try {
    await ConfigService.clearConfig(deleteAll: true);
    print('');
    print('✅ Configuration cleared successfully!');
    print('   ~/.architectify/ folder has been deleted.');
    print('');
    print('💡 Run architectify again to set up a new API key.');
  } catch (e) {
    print('');
    print('❌ Error clearing configuration: $e');
  }
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
  # First run - will prompt for API key and save it
  architectify ./lib/features/auth

  # Use with a user story to generate complete feature
  architectify ./lib/features/auth -s "As a user, I want to login with email and password"

  # Use MVVM pattern
  architectify ./lib/features/auth -p 2

  # Use pattern by name
  architectify ./lib/features/auth -p mvvm

  # Clear saved API key
  architectify --reset-key

  # Override saved key for this run
  architectify ./lib/features/auth -k sk-xxx

  # List all patterns
  architectify -l

CONFIGURATION:
  API key is saved to: ~/.architectify/config.json
  
  Priority order:
    1. --api-key / -k argument
    2. Saved config (~/.architectify/config.json)
    3. OPENAI_API_KEY environment variable
    4. Interactive prompt (first run)
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

  print('Use: architectify <folder> -p <number or name>');
  print('     architectify <folder> -s "User story text"');
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
