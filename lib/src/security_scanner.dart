import 'dart:convert';
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

  String? _lastReport;
  Map<String, String>? _lastFileContext;

  Future<String?> scan(Directory dir) async {
    print('');
    print('🛡️  Starting Security Scan...');
    print('   Target: ${dir.path}');
    print('   Model: $model');
    print('');

    if (!dir.existsSync()) {
      print('❌ Error: Directory not found: ${dir.path}');
      return null;
    }

    // 1. Gather all files
    final filesContent = await _gatherFiles(dir);
    if (filesContent.isEmpty) {
      print('⚠️  No relevant files found to scan.');
      return null;
    }

    _lastFileContext = filesContent;

    print('📦 Analyzing ${filesContent.length} files...');

    // 2. Send to AI
    _lastReport = await _analyzeWithAI(filesContent);
    return _lastReport;
  }

  Future<void> fixIssues(Directory dir) async {
    if (_lastReport == null || _lastFileContext == null) {
      print('❌ No scan report available to fix. Run scan() first.');
      return;
    }

    print('🔧 Attempting to auto-fix security issues with $model...');
    print('   (This process implements RASP principles and fixes vulnerabilities)');
    print('');

    // RASP-focused prompt
    final prompt = '''
You are an expert Security Engineer specializing in RASP (Runtime Application Self-Protection) and secure coding. state-of-the-art security fixes.
Your task is to FIX the security vulnerabilities identified in the previous report and IMPLEMENT RASP controls where applicable.

REPORT TO FIX:
$_lastReport

CODEBASE CONTEXT:
${_lastFileContext!.entries.map((e) => '--- FILE: ${e.key} ---\n${e.value}').join('\n\n')}

INSTRUCTIONS:
1. Apply code fixes for the Critical and High severity issues mentioned in the report.
2. **IMPLEMENT RASP CONTROLS**:
   - Add checks for Root/Jailbreak detection if missing.
   - Add checks for Debugger detection if missing.
   - Suggest or add necessary Flutter packages (e.g., `flutter_jailbreak_detection`, `freerasp`) in `pubspec.yaml` if needed.
3. Return the FULL content of the modified files.
4. If a file needs no changes, DO NOT include it in the response.
5. If you add dependencies, include the updated `pubspec.yaml`.

FORMAT:
Return a valid JSON object where keys are the file paths (relative path as seen in context) and values are the NEW full content of the file.
Example:
{
  "lib/main.dart": "void main() { ... }",
  "pubspec.yaml": "name: ... dependencies: ..."
}

IMPORTANT: Return ONLY the raw JSON string. Do not wrap in markdown or code blocks.
''';

    try {
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
        temperature: 0.2,
      );

      var jsonResponse = result.choices.first.message.content?.first.text?.trim();
      
      if (jsonResponse == null) {
        print('❌ Failed to generate fixes.');
        return;
      }

      // Strip markdown code blocks if present
      if (jsonResponse.startsWith('```')) {
        jsonResponse = jsonResponse.replaceAll(RegExp(r'^```[a-z]*\n'), '').replaceAll(RegExp(r'\n```$'), '');
      }

      // Fix common JSON escaping issues (like \$ which is invalid in JSON but used by AI for Dart)
      jsonResponse = jsonResponse.replaceAll(r'\$', r'$');


      // Let's rely on dart:convert
      final Map<String, dynamic> fixes = jsonDecode(jsonResponse);

      if (fixes.isEmpty) {
        print('⚠️  No fixes generated.');
        return;
      }

      print('📝 Applying fixes to ${fixes.length} files...');

      for (final entry in fixes.entries) {
        final filePath = entry.key;
        var newContent = entry.value as String;

        // SANITIZATION: Strip markdown code blocks from the file content itself
        // The AI might return the content as "```dart\n...\n```" inside the JSON value
        if (newContent.contains('```')) {
           newContent = newContent.replaceAll(RegExp(r'^```[a-z]*\s*'), '').replaceAll(RegExp(r'\s*```$'), '');
        }
        
        final file = File(p.join(dir.path, filePath));
        if (await file.exists()) {
           await file.writeAsString(newContent);
           print('   ✅ Fixed: $filePath');
        } else {
           // Handle new files (e.g. if RASP needs a new utility class)
           await file.create(recursive: true);
           await file.writeAsString(newContent);
           print('   ✨ Created: $filePath');
        }
      }

      print('');
      print('✅ Auto-fix complete!');

    } catch (e) {
      print('❌ Fix application failed: $e');
    }
  }

  Future<void> compareReports(String oldReport, String newReport) async {
    print('⚖️  Comparing security reports...');
    
    final prompt = '''
You are a Security Auditor. Compare the following two security reports (Before Fixes vs After Fixes) and provide a diff summary.

OLD REPORT:
$oldReport

NEW REPORT:
$newReport

INSTRUCTIONS:
1. Identify which Critical/High issues were resolved.
2. Identify if any new issues were introduced.
3. explicitly mention added RASP protections (Root detection, Anti-tampering, etc.).
4. Provide a concise summary in Markdown.

Respond with the Markdown summary ONLY.
''';

    try {
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
        temperature: 0.2,
      );

      final comparison = result.choices.first.message.content?.first.text?.trim() ?? 'No comparison generated.';
      
      print('');
      print('📉 Report Comparison');
      print('=========================');
      print('');
      print(comparison);
      print('');
      print('=========================');

    } catch (e) {
      print('❌ Comparison failed: $e');
    }
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

  Future<String> _analyzeWithAI(Map<String, String> filesMap) async {
    final fileContext = filesMap.entries.map((e) => '--- FILE: ${e.key} ---\n${e.value}').join('\n\n');
    
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
   - **RASP COMPLIANCE**: Check for absence of Root Detection, Jailbreak Detection, or Anti-Tampering mechanisms. Mark as High/Medium risk if missing for sensitive apps.

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
      
      return report;

    } catch (e) {
      print('❌ Analysis failed: $e');
      return 'Analysis Failed: $e';
    }
  }
}
