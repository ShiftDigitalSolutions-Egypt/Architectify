import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:path/path.dart' as p;

class SecurityScanner {
  final String apiKey;
  final String model;

  SecurityScanner({
    required this.apiKey,
    this.model = 'gpt-4o',
  }) {
    OpenAI.apiKey = apiKey;
  }

  Future<void> scan(Directory dir) async {
    print('');
    print('🛡️  Starting Security Scan...');
    print('   Target: ${dir.path}');
    print('   Model: $model');
    print('');

    if (!dir.existsSync()) {
      print('❌ Error: Directory not found: ${dir.path}');
      return;
    }

    // 1. Gather all files
    final filesContent = await _gatherFiles(dir);
    if (filesContent.isEmpty) {
      print('⚠️  No relevant files found to scan.');
      return;
    }

    print('📦 Analyzing ${filesContent.length} files...');

    // 2. Send to AI
    await _analyzeWithAI(filesContent);
  }

  Future<Map<String, String>> _gatherFiles(Directory dir) async {
    final filesMap = <String, String>{};
    final acceptedExtensions = {'.dart', '.yaml', '.json', '.xml', '.gradle', '.plist'};
    final ignoredDirs = {'.git', 'build', '.dart_tool', 'ios/Pods', 'android/.gradle'};

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final ext = p.extension(entity.path);
        
        // Check ignored dirs
        bool isIgnored = false;
        for (final ignored in ignoredDirs) {
          if (entity.path.contains('/$ignored/') || entity.path.contains('\\$ignored\\')) {
            isIgnored = true;
            break;
          }
        }
        if (isIgnored) continue;

        if (acceptedExtensions.contains(ext)) {
          try {
            // Skip large files (> 50KB for now to save tokens/complexity)
            final stat = await entity.stat();
            if (stat.size > 50 * 1024) continue;

            final content = await entity.readAsString();
            final relativePath = p.relative(entity.path, from: dir.path);
            filesMap[relativePath] = content;
          } catch (e) {
            // Ignore read errors
          }
        }
      }
    }
    return filesMap;
  }

  Future<void> _analyzeWithAI(Map<String, String> filesMap) async {
    final fileContext = filesMap.entries.map((e) => '--- FILE: ${e.key} ---\n${e.value}').join('\n\n');
    
    // Chunking logic could go here if files are too big, but for now we'll assume they fit given the exclusion of large files.
    // GPT-4o has a large context window (128k), so we can fit quite a bit.

    final prompt = '''
You are an expert Security Engineer and Code Auditor. Your task is to analyze the provided codebase for security vulnerabilities, best practice violations, and potential risks.

CODEBASE CONTEXT:
$fileContext

INSTRUCTIONS:
1. Analyze the code for:
   - Security vulnerabilities (Injection, auth issues, data leakage, weak crypto, etc.)
   - Dangerous dependencies or insecure configurations (in pubspec.yaml, etc.)
   - Hardcoded secrets or keys
   - Logic flaws that could be exploited
   - Flutter/Dart specific security best practices

2. Provide a detailed report in Markdown format.
3. Structure the report as follows:
   - 🛡️ **Executive Summary**: Brief overview of the security posture.
   - 🚨 **Critical Issues**: High severity vulnerabilities that need immediate fix.
   - ⚠️ **Warnings**: Potential issues or code smells.
   - ℹ️ **Improvement Suggestions**: Recommendations for better security.
   - 📦 **Dependency Analysis**: Comments on used packages.

4. If everything looks safe, say so, but suggest general hardening techniques.
5. Be specific: cite the file name and line numbers where possible.

Respond with the Markdown report ONLY.
''';

    try {
      print('⏳ Sending analysis request to $model (this may take a minute)...');
      
      final result = await OpenAI.instance.chat.create(
        model: model,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ],
          )
        ],
        temperature: 0.2, // Low temperature for analytical consistency
      );

      final report = result.choices.first.message.content?.first.text?.trim() ?? 'No report generated.';

      print('');
      print('📊 Security Scan Report');
      print('=========================');
      print('');
      print(report);
      print('');
      print('=========================');
      print('✅ Scan Complete');

    } catch (e) {
      print('❌ Analysis failed: $e');
    }
  }
}
