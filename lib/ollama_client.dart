import 'dart:convert';

import 'package:http/http.dart' as http;

import 'trustscore_model.dart';

/// Connection settings for the Ollama server that runs on the operator's
/// laptop. They can be set at build time with
/// `--dart-define=OLLAMA_BASE_URL=...` / `--dart-define=OLLAMA_MODEL=...`
/// and changed at runtime on the Settings screen.
class OllamaConfig {
  const OllamaConfig({
    required this.baseUrl,
    required this.model,
    this.enabled = true,
  });

  final String baseUrl;
  final String model;
  final bool enabled;

  static const defaultBaseUrl = String.fromEnvironment(
    'OLLAMA_BASE_URL',
    defaultValue: 'http://127.0.0.1:11434',
  );
  static const defaultModel = String.fromEnvironment(
    'OLLAMA_MODEL',
    defaultValue: 'llama3.2',
  );
  static const defaultEnabled = bool.fromEnvironment(
    'OLLAMA_ENABLED',
    defaultValue: true,
  );

  factory OllamaConfig.fromEnvironment() => const OllamaConfig(
        baseUrl: defaultBaseUrl,
        model: defaultModel,
        enabled: defaultEnabled,
      );

  OllamaConfig copyWith({String? baseUrl, String? model, bool? enabled}) =>
      OllamaConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        enabled: enabled ?? this.enabled,
      );

  /// Accepts `192.168.1.20:11434` as well as a full URL and removes trailing
  /// slashes so endpoints can be appended safely.
  String get resolvedBaseUrl {
    var url = baseUrl.trim();
    if (url.isEmpty) return defaultBaseUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    return url.replaceFirst(RegExp(r'/+$'), '');
  }

  String get resolvedModel =>
      model.trim().isEmpty ? defaultModel : model.trim();

  Uri get chatUri => Uri.parse('$resolvedBaseUrl/api/chat');
  Uri get tagsUri => Uri.parse('$resolvedBaseUrl/api/tags');

  @override
  bool operator ==(Object other) =>
      other is OllamaConfig &&
      other.baseUrl == baseUrl &&
      other.model == model &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(baseUrl, model, enabled);
}

class OllamaException implements Exception {
  const OllamaException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin client for the parts of the Ollama HTTP API this demo uses.
///
/// Only evidence features are ever sent. Names, identifiers and any other
/// applicant details stay inside the app.
class OllamaClient {
  OllamaClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  void close() => _client.close();

  static const _featureDescriptions = {
    'utility_payment_consistency_pct':
        'Utility payment consistency over the reviewed period (percent, 0-100)',
    'rent_payment_reliability_pct':
        'Rent payment reliability over the reviewed period (percent, 0-100)',
    'verified_income_regularity_pct':
        'Verified income regularity (percent, 0-100)',
    'previous_loan_repayment_history':
        'Previous loans repaid in full (count, 0-99)',
    'missed_payments_count_12m':
        'Missed payments in the last 12 months (count, 0-99)',
    'existing_financial_obligations_ratio':
        'Existing financial obligations as a share of income (ratio, 0-1)',
  };

  static const _systemPrompt = '''
You are the TrustScore assessment model in a financial-inclusion prototype.
You produce a supplementary, explainable financial-behaviour assessment from
synthetic evidence.

Rules:
- Reply with one JSON object only. No markdown fences, no prose around it.
- Never approve or reject a loan, and never state affordability.
- Missing evidence must not be treated as negative behaviour.
- The score is an integer from 0 to 1000, where higher means more consistent
  and verifiable financial behaviour.
- Use only the evidence provided. Do not invent facts.
- Keep each factor under 12 words.

Return exactly this shape:
{"status":"scored","score":<integer 0-1000>,"probability":<number 0-1>,
"positive_factors":[<up to 3 short strings>],
"negative_factors":[<up to 3 short strings>],
"limitation":"<one short sentence>"}

If the evidence is too sparse for a fair score, return
{"status":"insufficient_evidence","positive_factors":[],
"negative_factors":[],"limitation":"<one short sentence>"}
''';

  Future<TrustScoreAssessment> assess({
    required OllamaConfig config,
    required Map<String, double?> evidence,
    required int requiredFeatures,
  }) async {
    final presentFeatures =
        evidence.values.where((value) => value != null).length;
    final userPrompt = _evidencePrompt(evidence);
    final response = await _client
        .post(
          config.chatUri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': config.resolvedModel,
            'stream': false,
            'format': 'json',
            'options': {'temperature': 0},
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw OllamaException(
        'Ollama returned HTTP ${response.statusCode}. '
        'Check that the model "${config.resolvedModel}" is installed.',
      );
    }

    final content = _messageContent(response.bodyBytes);
    final json = _decodeJsonObject(content);
    final version = 'ollama/${config.resolvedModel}';
    final limitation = (json['limitation'] as String?)?.trim();

    final rawStatus = (json['status'] as String?)?.trim().toLowerCase();
    if (rawStatus == 'insufficient_evidence' || rawStatus == 'insufficient') {
      return TrustScoreAssessment(
        status: 'insufficient_evidence',
        modelVersion: version,
        presentFeatures: presentFeatures,
        requiredFeatures: requiredFeatures,
        limitation: limitation?.isNotEmpty == true
            ? limitation!
            : 'Missing evidence is not treated as negative financial behaviour.',
        engine: 'ollama',
      );
    }

    final rawScore = _toDouble(json['score'] ?? json['trust_score']);
    if (rawScore == null) {
      throw const OllamaException(
          'Ollama did not return a numeric trust score.');
    }
    final score = rawScore.round().clamp(0, 1000);
    final probability =
        (_toDouble(json['probability']) ?? score / 1000).clamp(0.0, 1.0);

    return TrustScoreAssessment(
      status: 'scored',
      modelVersion: version,
      score: score,
      probability: probability.toDouble(),
      presentFeatures: presentFeatures,
      requiredFeatures: requiredFeatures,
      limitation: limitation?.isNotEmpty == true
          ? limitation!
          : 'Supplementary output from a local Ollama model; '
              'not a lending or affordability decision.',
      engine: 'ollama',
      positiveFactors: _stringList(
        json['positive_factors'] ?? json['positiveFactors'],
      ),
      negativeFactors: _stringList(
        json['negative_factors'] ?? json['negativeFactors'],
      ),
    );
  }

  /// Returns the model names installed on the Ollama server. Used by the
  /// Settings screen to confirm the app can reach the laptop.
  Future<List<String>> listModels(OllamaConfig config) async {
    final response =
        await _client.get(config.tagsUri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw OllamaException('Ollama returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const OllamaException('Ollama returned an unexpected response.');
    }
    final models = decoded['models'];
    if (models is! List) return const [];
    return [
      for (final model in models)
        if (model is Map && model['name'] is String) model['name'] as String,
    ];
  }

  static String _evidencePrompt(Map<String, double?> evidence) {
    final buffer = StringBuffer('Synthetic applicant evidence:\n');
    for (final entry in evidence.entries) {
      final description =
          _featureDescriptions[entry.key] ?? entry.key.replaceAll('_', ' ');
      final value = entry.value == null
          ? 'missing (do not treat as negative)'
          : _formatValue(entry.key, entry.value!);
      buffer.writeln('- $description: $value');
    }
    buffer.write('\nReturn the JSON assessment object now.');
    return buffer.toString();
  }

  static String _formatValue(String key, double value) {
    if (key.endsWith('_ratio')) return value.toStringAsFixed(3);
    return value.toStringAsFixed(1);
  }

  static String _messageContent(List<int> bodyBytes) {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const OllamaException('Ollama returned an unexpected response.');
    }
    final message = decoded['message'];
    if (message is Map && message['content'] is String) {
      return message['content'] as String;
    }
    // Non-chat endpoints (/api/generate) return a top-level `response`.
    if (decoded['response'] is String) return decoded['response'] as String;
    throw const OllamaException('Ollama returned no message content.');
  }

  static Map<String, dynamic> _decodeJsonObject(String content) {
    final trimmed = content.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const OllamaException('Ollama did not return a JSON object.');
    }
    final decoded = jsonDecode(trimmed.substring(start, end + 1));
    if (decoded is! Map<String, dynamic>) {
      throw const OllamaException('Ollama did not return a JSON object.');
    }
    return decoded;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
