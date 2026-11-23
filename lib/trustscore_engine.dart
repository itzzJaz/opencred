import 'ollama_client.dart';
import 'trustscore_model.dart';

/// Chooses where a TrustScore comes from.
///
/// The evidence-sufficiency gate always runs first: sparse evidence never
/// reaches either model. When Ollama is enabled and reachable, the laptop
/// model scores the profile. If the laptop cannot be reached, the bundled
/// deterministic Random Forest keeps the offline demo working.
class TrustScoreEngine {
  const TrustScoreEngine._();

  static Future<TrustScoreAssessment> assess({
    required TrustScoreModel local,
    required Map<String, double?> evidence,
    required OllamaConfig config,
    OllamaClient? client,
  }) async {
    final presentFeatures =
        evidence.values.where((value) => value != null).length;
    if (presentFeatures < local.requiredFeatures) {
      // No-score is not a low score, so do not ask either model.
      return local.assess(evidence);
    }

    if (config.enabled) {
      final ollama = client ?? OllamaClient();
      try {
        return await ollama.assess(
          config: config,
          evidence: evidence,
          requiredFeatures: local.requiredFeatures,
        );
      } catch (_) {
        // The demo is offline-first: fall through to the bundled model and
        // let the UI label the result as a local fallback.
      } finally {
        if (client == null) ollama.close();
      }
    }

    return local.assess(evidence);
  }
}
