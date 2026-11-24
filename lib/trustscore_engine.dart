import 'models.dart';
import 'ollama_client.dart';
import 'trustscore_assessment.dart';

/// Runs the sole scoring engine and exposes the cache payload for persistence.
class TrustScoreEngine {
  const TrustScoreEngine._();

  static Future<({TrustScoreAssessment assessment, OllamaScoreCache? cache})>
      assessDetailed({
    required Map<String, double?> evidence,
    required OllamaConfig config,
    String? description,
    OllamaClient? client,
  }) async {
    final hasNumbers = evidence.values.any((value) => value != null);
    final hasDescription = description?.trim().isNotEmpty ?? false;
    final presentFeatures = evidence.values.where((v) => v != null).length;

    if (!hasNumbers && !hasDescription) {
      return (
        assessment: TrustScoreAssessment(
          status: 'insufficient_evidence',
          modelVersion: 'ollama/${config.resolvedModel}',
          presentFeatures: presentFeatures,
          limitation: 'Add financial evidence or a plain-English description.',
        ),
        cache: null,
      );
    }
    if (!config.enabled) {
      return (
        assessment: TrustScoreAssessment(
          status: 'insufficient_evidence',
          modelVersion: 'ollama/${config.resolvedModel}',
          presentFeatures: presentFeatures,
          limitation: 'Ollama scoring is disabled in Settings.',
        ),
        cache: null,
      );
    }

    final ollama = client ?? OllamaClient();
    try {
      final result = await ollama.assessTriple(
        config: config,
        evidence: evidence,
        description: description,
      );
      return (
        assessment: result.cache.toAssessment(presentFeatures),
        cache: result.cache,
      );
    } finally {
      if (client == null) ollama.close();
    }
  }
}
