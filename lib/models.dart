import 'dart:async';

import 'package:flutter/material.dart';
import 'ollama_client.dart';
import 'trustscore_assessment.dart';

enum AssessmentPathway { trustScore, alternative }

/// Scores evidence against a [OllamaConfig]. Injected by the app so the demo
/// state can stay free of networking and asset loading.
typedef TrustScoreAssessor = Future<TrustScoreAssessment> Function(
    Map<String, double?> evidence, OllamaConfig config,
    [String? description, bool force]);

/// Cached result from 3 Ollama scoring runs with their average.
class OllamaScoreCache {
  const OllamaScoreCache({
    required this.scores,
    required this.averageScore,
    required this.averageProbability,
    required this.positiveFactors,
    required this.negativeFactors,
    required this.limitation,
    required this.modelVersion,
    required this.timestamp,
    required this.judgeExplanation,
  });

  final List<int> scores;
  final int averageScore;
  final double averageProbability;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final String limitation;
  final String modelVersion;
  final DateTime timestamp;
  final String judgeExplanation;

  TrustScoreAssessment toAssessment(int presentFeatures) =>
      TrustScoreAssessment(
        status: 'scored',
        modelVersion: modelVersion,
        score: averageScore,
        probability: averageProbability,
        presentFeatures: presentFeatures,
        limitation: limitation,
        positiveFactors: positiveFactors,
        negativeFactors: negativeFactors,
        runScores: scores,
        judgeExplanation: judgeExplanation,
      );

  factory OllamaScoreCache.fromAssessments(
    List<TrustScoreAssessment> assessments,
    String modelVersion,
  ) {
    if (assessments.length != 3 || assessments.any((a) => !a.hasScore)) {
      throw ArgumentError('A saved Ollama score requires 3 scored runs.');
    }
    final scores = assessments.map((a) => a.score ?? 0).toList();
    final avgScore = (scores.reduce((a, b) => a + b) / scores.length).round();
    final avgProb =
        assessments.map((a) => a.probability ?? 0.0).reduce((a, b) => a + b) /
            assessments.length;
    return OllamaScoreCache(
      scores: scores,
      averageScore: avgScore.clamp(0, 1000),
      averageProbability: avgProb.clamp(0.0, 1.0),
      positiveFactors:
          assessments.expand((a) => a.positiveFactors).toSet().take(3).toList(),
      negativeFactors:
          assessments.expand((a) => a.negativeFactors).toSet().take(3).toList(),
      limitation: assessments.first.limitation.isNotEmpty
          ? assessments.first.limitation
          : 'Average of 3 Ollama scoring runs.',
      modelVersion: modelVersion,
      timestamp: DateTime.now(),
      judgeExplanation: assessments.first.judgeExplanation,
    );
  }

  Map<String, Object?> toJson() => {
        'scores': scores,
        'averageScore': averageScore,
        'averageProbability': averageProbability,
        'positiveFactors': positiveFactors,
        'negativeFactors': negativeFactors,
        'limitation': limitation,
        'modelVersion': modelVersion,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'judgeExplanation': judgeExplanation,
      };

  factory OllamaScoreCache.fromJson(Map<String, dynamic> json) =>
      OllamaScoreCache(
        scores:
            (json['scores'] as List).cast<num>().map((n) => n.toInt()).toList(),
        averageScore: (json['averageScore'] as num).toInt(),
        averageProbability: (json['averageProbability'] as num).toDouble(),
        positiveFactors: (json['positiveFactors'] as List).cast<String>(),
        negativeFactors: (json['negativeFactors'] as List).cast<String>(),
        limitation: json['limitation'] as String,
        modelVersion: json['modelVersion'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        judgeExplanation: json['judgeExplanation'] as String? ?? '',
      );
}

class FinancialRecord {
  const FinancialRecord({
    required this.month,
    required this.rent,
    required this.utilities,
    required this.income,
    required this.repayment,
  });

  final String month;
  final double? rent;
  final double? utilities;
  final double? income;
  final String repayment;
}

class Applicant {
  const Applicant({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarAsset,
    required this.role,
    required this.summary,
    required this.evidenceLabel,
    required this.evidenceValue,
    required this.pathway,
    required this.records,
    required this.positiveFactors,
    required this.negativeFactors,
    this.evidence,
    this.assessment,
    this.description,
  });

  final String id;
  final String name;
  final String initials;
  final String avatarAsset;
  final String role;
  final String summary;
  final String evidenceLabel;
  final double evidenceValue;
  final AssessmentPathway pathway;
  final List<FinancialRecord> records;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final Map<String, double?>? evidence;
  final TrustScoreAssessment? assessment;
  final String? description;

  bool get hasScore => pathway == AssessmentPathway.trustScore;
  int? get trustScore => assessment?.score;
  double get evidenceCompleteness => records.isEmpty
      ? 0
      : records.where((record) => record.income != null).length /
          records.length;

  Applicant copyWith({
    String? role,
    String? summary,
    String? evidenceLabel,
    double? evidenceValue,
    AssessmentPathway? pathway,
    List<String>? positiveFactors,
    List<String>? negativeFactors,
    TrustScoreAssessment? assessment,
    String? description,
    bool clearDescription = false,
  }) =>
      Applicant(
        id: id,
        name: name,
        initials: initials,
        avatarAsset: avatarAsset,
        role: role ?? this.role,
        summary: summary ?? this.summary,
        evidenceLabel: evidenceLabel ?? this.evidenceLabel,
        evidenceValue: evidenceValue ?? this.evidenceValue,
        pathway: pathway ?? this.pathway,
        records: records,
        positiveFactors: positiveFactors ?? this.positiveFactors,
        negativeFactors: negativeFactors ?? this.negativeFactors,
        evidence: evidence,
        assessment: assessment ?? this.assessment,
        description: clearDescription ? null : description ?? this.description,
      );
}

class DemoState extends ChangeNotifier {
  DemoState(List<Applicant> source, {TrustScoreAssessor? assessor})
      : _seed = List<Applicant>.of(source),
        applicants = List<Applicant>.of(source),
        _assessor = assessor {
    selected = applicants.first;
  }

  @override
  void dispose() {
    _profileSwitchTimer?.cancel();
    super.dispose();
  }

  /// The immutable seeded profiles. Reset restores this list, so anything
  /// created during a session is removed without touching the caller's list.
  final List<Applicant> _seed;
  final List<Applicant> applicants;
  final TrustScoreAssessor? _assessor;
  late Applicant selected;
  int tabIndex = 0;
  bool identityVerified = false;
  bool consentGranted = false;
  bool assessmentStarted = false;
  Applicant? profileSwitchFrom;
  bool profileSwitching = false;
  Timer? _profileSwitchTimer;
  bool showWelcome = true;
  bool judgeLensEnabled = false;
  String applicationStatus = 'Under review';
  ThemeMode themeMode = ThemeMode.system;
  final Map<String, String> _notes = {};

  /// Ollama server configuration used by all profile scoring.
  OllamaConfig ollamaConfig = OllamaConfig.fromEnvironment();
  bool ollamaBusy = false;
  String? ollamaMessage;
  final Set<String> _ollamaAttempted = {};

  /// The next free id after the seeded range and any profiles created since.
  String get nextApplicantId {
    var highest = 1499;
    for (final applicant in applicants) {
      final numeric = int.tryParse(applicant.id.replaceFirst('TS-', ''));
      if (numeric != null && numeric > highest) highest = numeric;
    }
    return 'TS-${highest + 1}';
  }

  String noteFor(String applicantId) => _notes[applicantId] ?? '';

  void setNote(String applicantId, String note) {
    if (note.trim().isEmpty) {
      _notes.remove(applicantId);
    } else {
      _notes[applicantId] = note;
    }
    // The text field already owns the visible text. Notifying on every
    // keystroke would rebuild the whole shell without changing the screen.
  }

  void addApplicant(Applicant applicant) {
    applicants.insert(0, applicant);
    if (applicant.assessment?.isOllama ?? false) {
      // The create form already scored this profile on the laptop, so the
      // assessment screen should not ask Ollama again immediately.
      _ollamaAttempted.add(applicant.id);
    }
    selectApplicant(applicant);
  }

  void updateApplicant(Applicant applicant) {
    final index = applicants.indexWhere((item) => item.id == applicant.id);
    if (index < 0) return;
    applicants[index] = applicant;
    if (selected.id == applicant.id) selected = applicant;
    _ollamaAttempted.remove(applicant.id);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void toggleJudgeLens() {
    judgeLensEnabled = !judgeLensEnabled;
    notifyListeners();
  }

  void setOllamaConfig(OllamaConfig config) {
    if (ollamaConfig == config) return;
    ollamaConfig = config;
    _ollamaAttempted.clear();
    ollamaMessage = null;
    notifyListeners();
  }

  /// Asks the laptop model to re-score one applicant (3 runs, averaged).
  /// A profile is only sent once per config unless [force] is set or evidence
  /// has changed. The averaged result is cached per applicant.
  Future<void> assessWithOllama(String applicantId,
      {bool force = false}) async {
    final assessor = _assessor;
    if (assessor == null || !ollamaConfig.enabled || ollamaBusy) return;

    final index =
        applicants.indexWhere((applicant) => applicant.id == applicantId);
    if (index < 0) return;
    final current = applicants[index];
    final evidence = current.evidence;
    if ((evidence == null || evidence.values.every((value) => value == null)) &&
        (current.description == null || current.description!.trim().isEmpty)) {
      return;
    }

    // Check if we need to rescore (force, never attempted, or evidence changed)
    final needsRescore = force || !_ollamaAttempted.contains(applicantId);
    if (!needsRescore) return;

    _ollamaAttempted.add(applicantId);
    ollamaBusy = true;
    ollamaMessage = null;
    notifyListeners();
    try {
      final assessment = await assessor(
          evidence ?? const {}, ollamaConfig, current.description, force);
      _applyAssessment(applicantId, assessment);
      ollamaMessage = null;
    } catch (error) {
      _ollamaAttempted.remove(applicantId);
      ollamaMessage = 'Ollama unavailable — $error';
    } finally {
      ollamaBusy = false;
      notifyListeners();
    }
  }

  void _applyAssessment(String applicantId, TrustScoreAssessment assessment) {
    final index =
        applicants.indexWhere((applicant) => applicant.id == applicantId);
    if (index < 0) return;
    final current = applicants[index];
    final hasScore = assessment.hasScore;
    final evidenceCount = current.evidence?.length ?? 6;
    final updated = current.copyWith(
      role: hasScore ? 'Evidence available' : 'Evidence still developing',
      summary: hasScore
          ? 'A model assessment is available from the submitted evidence.'
          : 'There is not enough evidence for a fair model assessment.',
      evidenceLabel: hasScore ? 'Sufficient evidence' : 'Insufficient evidence',
      evidenceValue: evidenceCount == 0
          ? current.evidenceValue
          : assessment.presentFeatures / evidenceCount,
      pathway: hasScore
          ? AssessmentPathway.trustScore
          : AssessmentPathway.alternative,
      positiveFactors: assessment.positiveFactors.isNotEmpty
          ? assessment.positiveFactors
          : current.positiveFactors,
      negativeFactors: assessment.negativeFactors.isNotEmpty
          ? assessment.negativeFactors
          : current.negativeFactors,
      assessment: assessment,
    );
    applicants[index] = updated;
    if (selected.id == applicantId) selected = updated;
  }

  void selectApplicant(Applicant applicant) {
    if (selected.id != applicant.id) {
      profileSwitchFrom = selected;
      profileSwitching = true;
      _profileSwitchTimer?.cancel();
      _profileSwitchTimer = Timer(const Duration(milliseconds: 1850), () {
        profileSwitching = false;
        profileSwitchFrom = null;
        notifyListeners();
      });
    }
    selected = applicant;
    identityVerified = false;
    consentGranted = false;
    assessmentStarted = false;
    notifyListeners();
  }

  void dismissProfileSwitch() {
    _profileSwitchTimer?.cancel();
    profileSwitching = false;
    profileSwitchFrom = null;
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void verifyIdentity() {
    identityVerified = true;
    notifyListeners();
  }

  void grantConsent() {
    consentGranted = true;
    notifyListeners();
  }

  void startAssessment() {
    assessmentStarted = true;
    notifyListeners();
  }

  void startDemo() {
    showWelcome = false;
    notifyListeners();
  }

  void reset() {
    _profileSwitchTimer?.cancel();
    profileSwitching = false;
    profileSwitchFrom = null;
    applicants
      ..clear()
      ..addAll(_seed);
    _notes.clear();
    _ollamaAttempted.clear();
    ollamaMessage = null;
    ollamaBusy = false;
    selected = applicants.first;
    tabIndex = 0;
    identityVerified = false;
    consentGranted = false;
    assessmentStarted = false;
    showWelcome = true;
    applicationStatus = 'Under review';
    notifyListeners();
  }
}
