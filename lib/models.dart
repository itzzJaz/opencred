import 'package:flutter/foundation.dart';

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

  bool get hasScore => pathway == AssessmentPathway.trustScore;
  double get evidenceCompleteness =>
      records.isEmpty ? 0 : records.where((record) => record.income != null).length / records.length;
}

class DemoState extends ChangeNotifier {
  DemoState(this.applicants) : selected = applicants.first;

  final List<Applicant> applicants;
  late Applicant selected;
  int tabIndex = 0;
  bool identityVerified = false;
  bool consentGranted = false;
  bool assessmentStarted = false;
  bool showWelcome = true;
  String applicationStatus = 'Under review';

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
