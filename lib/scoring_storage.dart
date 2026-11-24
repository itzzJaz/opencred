import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Persistent local cache for Ollama scores, keyed by a stable digest of the
/// complete scoring inputs. Changing any input produces a cache miss.
class ScoringStorage {
  const ScoringStorage();

  static const _keyPrefix = 'ollama_score_v1_';

  static String profileHash(
    Map<String, double?> evidence, {
    String? description,
  }) {
    final values = (evidence.keys.toList()..sort())
        .map((key) => '$key=${evidence[key]?.toString() ?? 'null'}')
        .join('\n');
    final canonical = '$values\ndescription=${description?.trim() ?? ''}';
    // Stable 64-bit FNV-1a digest; unlike Object.hashCode this is stable across
    // application launches and Dart VM processes.
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode(canonical)) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<OllamaScoreCache?> read(String profileHash) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString('$_keyPrefix$profileHash');
    if (encoded == null) return null;
    try {
      return OllamaScoreCache.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>);
    } catch (_) {
      await preferences.remove('$_keyPrefix$profileHash');
      return null;
    }
  }

  Future<void> write(String profileHash, OllamaScoreCache cache) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        '$_keyPrefix$profileHash', jsonEncode(cache.toJson()));
  }
}
