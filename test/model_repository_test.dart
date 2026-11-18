import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/demo_repository.dart';
import 'package:opencred/trustscore_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads every CSV applicant and applies the model pathway gate',
      () async {
    final applicants = await DemoRepository.loadApplicants();

    expect(applicants.length, 500);
    expect(applicants.every((applicant) => applicant.id.startsWith('TS-')),
        isTrue);
    expect(applicants.any((applicant) => applicant.hasScore), isTrue);
    expect(applicants.every((applicant) => applicant.hasScore), isTrue);
    expect(
        applicants.every((applicant) => applicant.trustScore != null), isTrue);

    final model = await TrustScoreModel.load();
    final missing = model.assess({
      'utility_payment_consistency_pct': null,
      'rent_payment_reliability_pct': null,
      'previous_loan_repayment_history': null,
      'missed_payments_count_12m': null,
      'verified_income_regularity_pct': 80,
      'existing_financial_obligations_ratio': null,
    });
    expect(missing.status, 'insufficient_evidence');
    expect(missing.score, isNull);
  });
}
