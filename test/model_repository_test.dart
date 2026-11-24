import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/demo_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads every CSV applicant without an Ollama score cache', () async {
    final applicants = await DemoRepository.loadApplicants();

    expect(applicants.length, 500);
    expect(applicants.every((applicant) => applicant.id.startsWith('TS-')),
        isTrue);
    expect(applicants.every((applicant) => !applicant.hasScore), isTrue);
    expect(
        applicants.every((applicant) => applicant.trustScore == null), isTrue);
  });
}
