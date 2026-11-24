import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';
import 'ollama_client.dart';
import 'trustscore_engine.dart';
import 'trustscore_assessment.dart';
import 'scoring_storage.dart';

class DemoRepository {
  static const _scoringStorage = ScoringStorage();

  /// Reuses a profile-specific saved result, otherwise scores with Ollama.
  static Future<TrustScoreAssessment> assess(
      Map<String, double?> evidence, OllamaConfig config,
      [String? description, bool force = false]) async {
    final hash = ScoringStorage.profileHash(evidence, description: description);
    final saved = force ? null : await _scoringStorage.read(hash);
    if (saved != null) {
      return saved.toAssessment(
        evidence.values.where((value) => value != null).length,
      );
    }
    final result = await TrustScoreEngine.assessDetailed(
      evidence: evidence,
      config: config,
      description: description,
    );
    if (result.cache != null) {
      await _scoringStorage.write(hash, result.cache!);
    }
    return result.assessment;
  }

  /// Confirms the app can reach Ollama and returns the installed models.
  static Future<List<String>> testOllama(OllamaConfig config) async {
    final client = OllamaClient();
    try {
      return await client.listModels(config);
    } finally {
      client.close();
    }
  }

  static Future<List<Applicant>> loadApplicants() async {
    final csv = await rootBundle.loadString('assets/data/applicants.csv');
    final rows = _parseCsv(csv);
    if (rows.isEmpty) {
      throw const FormatException(
          'assets/data/applicants.csv contains no applicants');
    }

    return Future.wait(rows.asMap().entries.map((entry) async {
      final values = entry.value;
      final id = values['applicant_id'];
      if (id == null || id.isEmpty) {
        throw FormatException(
            'Applicant row ${entry.key + 2} has no applicant_id');
      }
      final evidence = {
        for (final feature in _features) feature: _number(values[feature]),
      };
      final cache = await _scoringStorage.read(
        ScoringStorage.profileHash(evidence),
      );
      final assessment = cache == null
          ? TrustScoreAssessment(
              status: 'insufficient_evidence',
              modelVersion: 'ollama/${OllamaConfig.defaultModel}',
              presentFeatures: evidence.values.where((v) => v != null).length,
              limitation: 'This profile has not been scored by Ollama yet.',
            )
          : cache.toAssessment(
              evidence.values.where((v) => v != null).length,
            );
      final hasScore = assessment.hasScore;
      final name = _nameFor(entry.key);
      return Applicant(
        id: id,
        name: name,
        initials: _initialsFor(name),
        avatarAsset: 'assets/images/trustscore_icon.jpg',
        role: hasScore ? 'Evidence available' : 'Evidence still developing',
        summary: hasScore
            ? 'A model assessment is available from the submitted evidence.'
            : 'There is not enough evidence for a fair model assessment.',
        evidenceLabel:
            hasScore ? 'Sufficient evidence' : 'Insufficient evidence',
        evidenceValue: assessment.presentFeatures / _features.length,
        pathway: hasScore
            ? AssessmentPathway.trustScore
            : AssessmentPathway.alternative,
        records: const [],
        positiveFactors: positiveFactors(evidence),
        negativeFactors: negativeFactors(evidence),
        evidence: evidence,
        assessment: assessment,
      );
    }).toList());
  }

  static const _features = [
    'utility_payment_consistency_pct',
    'rent_payment_reliability_pct',
    'previous_loan_repayment_history',
    'missed_payments_count_12m',
    'verified_income_regularity_pct',
    'existing_financial_obligations_ratio',
  ];

  /// 25 first names by 20 surnames gives one distinct pair per seeded row,
  /// in CSV order. Names are stable across runs so a judge can return to the
  /// same profile by name or id.
  static const _firstNames = [
    'Aisha',
    'Daniel',
    'Mercy',
    'Liam',
    'Nadia',
    'Elias',
    'Priya',
    'Noah',
    'Sofia',
    'Marcus',
    'Leila',
    'Owen',
    'Grace',
    'Tomas',
    'Amara',
    'Rahul',
    'Elena',
    'Kwame',
    'Hana',
    'Diego',
    'Ingrid',
    'Samir',
    'Chloe',
    'Mateo',
    'Zara',
  ];

  static const _surnames = [
    'Okafor',
    'Bennett',
    'Silva',
    'Rahman',
    'Larson',
    'Mensah',
    'Patel',
    'Moreau',
    'Novak',
    'Haddad',
    'Kimani',
    'Ferreira',
    'Nyberg',
    'Osei',
    'Tan',
    'Iyer',
    'Duarte',
    'Mwangi',
    'Kaur',
    'Andersen',
  ];

  static String _nameFor(int index) {
    final firstIndex = index % _firstNames.length;
    final block = index ~/ _firstNames.length;
    // Offset each block's surnames so consecutive rows do not read as one
    // family. The pairing stays unique across all 500 rows.
    final lastIndex = (block + firstIndex * 7) % _surnames.length;
    return '${_firstNames[firstIndex]} ${_surnames[lastIndex]}';
  }

  static String _initialsFor(String name) {
    final parts = name.split(' ');
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static double? _number(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  static List<String> positiveFactors(Map<String, double?> evidence) {
    final factors = <String>[];
    if ((evidence['verified_income_regularity_pct'] ?? 0) >= 70) {
      factors.add('Regular verified income');
    }
    if ((evidence['utility_payment_consistency_pct'] ?? 0) >= 75) {
      factors.add('Consistent utility payments');
    }
    return factors.isEmpty
        ? ['No strong positive indicator available']
        : factors;
  }

  static List<String> negativeFactors(Map<String, double?> evidence) {
    final factors = <String>[];
    if ((evidence['missed_payments_count_12m'] ?? 0) >= 2) {
      factors.add('Missed payments in the last 12 months');
    }
    if ((evidence['existing_financial_obligations_ratio'] ?? 0) >= .5) {
      factors.add('Higher existing obligations ratio');
    }
    return factors.isEmpty
        ? ['No strong negative indicator available']
        : factors;
  }

  static List<Map<String, String>> _parseCsv(String source) {
    final lines = const LineSplitter().convert(source.trim());
    if (lines.isEmpty) return [];
    final headers = _splitLine(lines.first);
    if (headers.contains('')) {
      throw const FormatException('CSV contains an empty header');
    }
    return [
      for (final line in lines.skip(1))
        if (line.trim().isNotEmpty)
          _row(headers, _splitLine(line), lines.indexOf(line) + 1),
    ];
  }

  static Map<String, String> _row(
      List<String> headers, List<String> values, int lineNumber) {
    if (headers.length != values.length) {
      throw FormatException(
          'CSV row $lineNumber has ${values.length} columns; expected ${headers.length}');
    }
    return Map.fromIterables(headers, values);
  }

  static List<String> _splitLine(String line) {
    final values = <String>[];
    var current = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final character = line[i];
      if (character == '"') {
        quoted = !quoted;
      } else if (character == ',' && !quoted) {
        values.add(current.toString().trim());
        current = StringBuffer();
      } else {
        current.write(character);
      }
    }
    values.add(current.toString().trim());
    return values;
  }
}
