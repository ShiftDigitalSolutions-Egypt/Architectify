library;

import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:path/path.dart' as p;

import 'design_patterns.dart';

/// Architectify - AI-powered Flutter Architecture Refactoring Tool
class ArchitectifyRefactor {
  final String featureDirPath;
  final String apiKey;
  final DesignPattern pattern;
  late final Directory featureDir;

  ArchitectifyRefactor({
    required this.featureDirPath,
    required this.apiKey,
    required this.pattern,
  }) {
    featureDir = Directory(featureDirPath);
    OpenAI.apiKey = apiKey;
  }

  /// Main entry point
  Future<void> run() async {
    if (!featureDir.existsSync()) {
      print('❌ Feature folder not found: $featureDirPath');
      return;
    }

    print('');
    print('🚀 Starting ${pattern.name} refactor for: $featureDirPath');
    print('');

    // 1️⃣ Ensure folder structure exists
    await _createStructure();

    // 2️⃣ Process all files in folder
    await _processFiles(featureDir);

    print('');
    print('✨ Refactor completed successfully!');
    print('📋 Your code is now organized using ${pattern.name}');
  }

  /// Ensure architecture folder structure based on selected pattern
  Future<void> _createStructure() async {
    print('📂 Creating ${pattern.name} folder structure...');
    for (final folder in pattern.folderStructure) {
      // Skip template folders with placeholders
      if (folder.contains('[')) continue;
      Directory(p.join(featureDir.path, folder)).createSync(recursive: true);
    }
  }

  /// Process all Dart files, send prompt to AI to generate missing files or update existing ones
  Future<void> _processFiles(Directory dir) async {
    final filesMap = <String, String>{};

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        try {
          final content = entity.readAsStringSync();
          final relativePath = p.relative(entity.path, from: featureDir.path);
          filesMap[relativePath] = content;
        } catch (e) {
          print('❌ Error reading file ${entity.path}: $e');
        }
      }
    }

    if (filesMap.isEmpty) {
      print('⚠️ No Dart files found in the feature folder');
      return;
    }

    print('🔄 Processing ${filesMap.length} files with AI...');

    // Send prompt to AI for full pipeline refactor
    final generatedFiles = await _generateAllMissingAndFixFiles(filesMap);

    if (generatedFiles.isEmpty) {
      print('⚠️ No files were generated. Check your API key and try again.');
      return;
    }

    // Write/update files
    for (final entry in generatedFiles.entries) {
      final filePath = p.join(featureDir.path, entry.key);
      File(filePath).createSync(recursive: true);
      File(filePath).writeAsStringSync(entry.value);
      print('✅ Wrote/updated: ${entry.key}');
    }
  }

  /// Send all files to AI and get a JSON map of all new/updated files
  Future<Map<String, String>> _generateAllMissingAndFixFiles(
      Map<String, String> filesMap) async {
    final filesContent =
        filesMap.entries.map((e) => '--- ${e.key} ---\n${e.value}').join('\n');

    final folderList = pattern.folderStructure.map((f) => '  - $f').join('\n');

    final prompt = '''
${pattern.aiPromptTemplate}

User provided the following files:
$filesContent

Target folder structure:
$folderList

Rules:
- Each Model MUST extend its corresponding Entity (e.g., AuthModel extends AuthEntity)
- Fields and constructors must match exactly between Entity and Model
- Add missing imports if necessary
- Only valid Dart code
- Output the Dart code for all files:
  - For each file, include a comment: // FILE: relative/path/to/file.dart
- No explanations, no extra classes, no extra text

Respond with Dart code only.
''';

    try {
      final result = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ],
          )
        ],
        temperature: 0,
      );

      final text =
          result.choices.first.message.content?.first.text?.trim() ?? '';

      // Extract files from text based on // FILE: comments
      final Map<String, String> generatedFiles = {};
      final regex = RegExp(r'// FILE: (.+)\n([\s\S]*?)(?=(\n// FILE:|$))');
      for (final match in regex.allMatches(text)) {
        final path = match.group(1)!.trim();
        final content = match.group(2)!.trim();
        if (path.isNotEmpty && content.isNotEmpty) {
          generatedFiles[path] = content;
        }
      }

      return generatedFiles;
    } catch (e) {
      print('⚠️ AI generation failed: $e');
      return {};
    }
  }
}
