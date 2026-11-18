import 'package:flutter/material.dart';
import 'trustscore_model.dart';

enum AssessmentPathway { trustScore, alternative }

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
}

class DemoState extends ChangeNotifier {
  DemoState(List<Applicant> source)
      : _seed = List<Applicant>.of(source),
        applicants = List<Applicant>.of(source) {
    selected = applicants.first;
  }

  /// The immutable seeded profiles. Reset restores this list, so anything
  /// created during a session is removed without touching the caller's list.
  final List<Applicant> _seed;
  final List<Applicant> applicants;
  late Applicant selected;
  int tabIndex = 0;
  bool identityVerified = false;
  bool consentGranted = false;
  bool assessmentStarted = false;
  bool showWelcome = true;
  String applicationStatus = 'Under review';
  ThemeMode themeMode = ThemeMode.system;
  final Map<String, String> _notes = {};

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
    selectApplicant(applicant);
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
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
