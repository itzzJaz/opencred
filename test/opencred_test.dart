import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/models.dart';

void main() {
  test('insufficient evidence uses alternative pathway without a score', () {
    const applicant = Applicant(
      id: 'arjun', name: 'Arjun Patel', initials: 'AP', role: 'Evidence still developing',
      avatarAsset: 'assets/images/arjun_profile.png',
      summary: 'Partial records', evidenceLabel: 'Insufficient evidence', evidenceValue: .42,
      pathway: AssessmentPathway.alternative, records: [], positiveFactors: [], negativeFactors: [],
    );
    expect(applicant.hasScore, isFalse);
    expect(applicant.pathway, AssessmentPathway.alternative);
  });
}
