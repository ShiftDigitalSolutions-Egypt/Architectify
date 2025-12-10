/// Configuration service for persistent API key storage
library;

import 'dart:convert';
import 'dart:io';

/// Manages persistent configuration stored in ~/.architectify/config.json
class ConfigService {
  static const String _configFileName = 'config.json';
  static const String _configDirName = '.architectify';

  /// Get the configuration directory path based on platform
  static String get configDir {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];

    if (home == null) {
      throw Exception('Could not determine home directory');
    }

    return '$home${Platform.pathSeparator}$_configDirName';
  }

  /// Get the full path to the config file
  static String get configFilePath => '$configDir${Platform.pathSeparator}$_configFileName';

  /// Check if configuration exists
  static bool get isConfigured {
    final file = File(configFilePath);
    if (!file.existsSync()) return false;

    try {
      final config = _loadConfig();
      final apiKey = config['api_key'] as String?;
      return apiKey != null && apiKey.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Load the saved API key
  static String? getApiKey() {
    try {
      final config = _loadConfig();
      return config['api_key'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Save the API key to persistent storage
  static Future<void> saveApiKey(String apiKey) async {
    final dir = Directory(configDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final config = _loadConfigSafe();
    config['api_key'] = apiKey;
    config['saved_at'] = DateTime.now().toIso8601String();

    final file = File(configFilePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(config),
    );
  }

  /// Clear the API key and optionally delete all config
  static Future<void> clearConfig({bool deleteAll = true}) async {
    if (deleteAll) {
      final dir = Directory(configDir);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } else {
      final file = File(configFilePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  /// Validate API key format (basic check)
  static bool isValidApiKeyFormat(String apiKey) {
    // OpenAI API keys start with 'sk-' and are reasonably long
    return apiKey.startsWith('sk-') && apiKey.length > 20;
  }

  /// Load config from file
  static Map<String, dynamic> _loadConfig() {
    final file = File(configFilePath);
    if (!file.existsSync()) {
      return {};
    }
    final content = file.readAsStringSync();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// Load config safely (returns empty map on error)
  static Map<String, dynamic> _loadConfigSafe() {
    try {
      return _loadConfig();
    } catch (_) {
      return {};
    }
  }
}
