import 'dart:convert';

import 'package:flutter/services.dart';

class TrustScoreAssessment {
  const TrustScoreAssessment({
    required this.status,
    required this.modelVersion,
    this.score,
    this.probability,
    required this.presentFeatures,
    required this.requiredFeatures,
    required this.limitation,
  });

  final String status;
  final String modelVersion;
  final int? score;
  final double? probability;
  final int presentFeatures;
  final int requiredFeatures;
  final String limitation;

  bool get hasScore => status == 'scored' && score != null;
}

class TrustScoreModel {
  TrustScoreModel._(this._model);

  final Map<String, dynamic> _model;

  static Future<TrustScoreModel> load() async {
    final source =
        await rootBundle.loadString('ml/artifacts/trustscore_model.json');
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'TrustScore model artifact must be a JSON object');
    }
    return TrustScoreModel._(decoded);
  }

  TrustScoreAssessment assess(Map<String, double?> evidence) {
    final featureNames = List<String>.from(_model['feature_names'] as List);
    final medians = Map<String, dynamic>.from(_model['medians'] as Map);
    final values = <double>[];
    var present = 0;
    for (final feature in featureNames) {
      final value = evidence[feature];
      if (value == null) {
        values.add((medians[feature] as num).toDouble());
      } else {
        values.add(value);
        present++;
      }
    }
    final required = (_model['min_features_for_score'] as num).toInt();
    final version = _model['model_version'] as String;
    if (present < required) {
      return TrustScoreAssessment(
        status: 'insufficient_evidence',
        modelVersion: version,
        presentFeatures: present,
        requiredFeatures: required,
        limitation:
            'Missing evidence is not treated as negative financial behaviour.',
      );
    }

    final trees = _model['trees'] as List;
    var probability = 0.0;
    for (final rawTree in trees) {
      final nodes = rawTree as List;
      var index = 0;
      while (true) {
        final node = Map<String, dynamic>.from(nodes[index] as Map);
        final feature = (node['feature'] as num).toInt();
        if (feature < 0) {
          final negative = (node['negative'] as num).toDouble();
          final positive = (node['positive'] as num).toDouble();
          probability += positive / (negative + positive);
          break;
        }
        index = values[feature] <= (node['threshold'] as num).toDouble()
            ? (node['left'] as num).toInt()
            : (node['right'] as num).toInt();
      }
    }
    probability /= trees.length;
    final score = (probability * 1000).round().clamp(0, 1000);
    return TrustScoreAssessment(
      status: 'scored',
      modelVersion: version,
      score: score,
      probability: probability,
      presentFeatures: present,
      requiredFeatures: required,
      limitation:
          'Supplementary prototype output; not a lending or affordability decision.',
    );
  }
}
