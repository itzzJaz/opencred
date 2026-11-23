import 'package:flutter/material.dart';
import 'ollama_client.dart';
import 'trustscore_model.dart';

enum AssessmentPathway { trustScore, alternative }

/// Scores evidence against a [OllamaConfig]. Injected by the app so the demo
/// state can stay free of networking and asset loading.
typedef TrustScoreAssessor = Future<TrustScoreAssessment> Function(
  Map<String, double?> evidence,
  OllamaConfig config,
);

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
      );
}

class DemoState extends ChangeNotifier {
  DemoState(List<Applicant> source, {TrustScoreAssessor? assessor})
      : _seed = List<Applicant>.of(source),
        applicants = List<Applicant>.of(source),
        _assessor = assessor {
    selected = applicants.first;
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
  bool showWelcome = true;
  String applicationStatus = 'Under review';
  ThemeMode themeMode = ThemeMode.system;
  final Map<String, String> _notes = {};

  /// The laptop Ollama server used for TrustScore. Seeded profiles start with
  /// the bundled model so startup stays instant, then the assessment screen
  /// re-scores the selected profile through Ollama.
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

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void setOllamaConfig(OllamaConfig config) {
    if (ollamaConfig == config) return;
    ollamaConfig = config;
    _ollamaAttempted.clear();
    ollamaMessage = null;
    notifyListeners();
  }

  /// Asks the laptop model to re-score one applicant. A profile is only sent
  /// once per config unless [force] is set, so switching tabs does not spam
  /// the server. The result replaces the bundled-model result for that profile.
  Future<void> assessWithOllama(String applicantId,
      {bool force = false}) async {
    final assessor = _assessor;
    if (assessor == null || !ollamaConfig.enabled || ollamaBusy) return;
    if (!force && _ollamaAttempted.contains(applicantId)) return;

    final index =
        applicants.indexWhere((applicant) => applicant.id == applicantId);
    if (index < 0) return;
    final evidence = applicants[index].evidence;
    if (evidence == null || evidence.values.every((value) => value == null)) {
      return;
    }

    _ollamaAttempted.add(applicantId);
    ollamaBusy = true;
    ollamaMessage = null;
    notifyListeners();
    try {
      final assessment = await assessor(evidence, ollamaConfig);
      _applyAssessment(applicantId, assessment);
      if (assessment.status == 'scored' && !assessment.isOllama) {
        ollamaMessage =
            'Ollama is unreachable. The bundled model scored this profile.';
      }
    } catch (_) {
      _ollamaAttempted.remove(applicantId);
      ollamaMessage =
          'Ollama is unreachable. The bundled model scored this profile.';
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
    selected = applicant;
    identityVerified = false;
    consentGranted = false;
    assessmentStarted = false;
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
