import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/app.dart';
import 'package:opencred/models.dart';

void main() {
  testWidgets('starts the OpenCred demonstration', (WidgetTester tester) async {
    const applicant = Applicant(
      id: 'ravi',
      name: 'Ravi Kumar',
      initials: 'RK',
      avatarAsset: 'assets/images/ravi_profile.png',
      role: 'Consistent household finances',
      summary: 'Strong evidence',
      evidenceLabel: 'High evidence',
      evidenceValue: .94,
      pathway: AssessmentPathway.trustScore,
      records: [],
      positiveFactors: [],
      negativeFactors: [],
    );

    await tester.pumpWidget(const OpenCredApp(applicants: [applicant]));
    expect(find.textContaining('Trust beyond'), findsOneWidget);

    await tester.tap(find.text('Start demonstration'));
    await tester.pump();

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.byTooltip('Switch profile'), findsOneWidget);
  });

  testWidgets('opens assessment after completing the journey', (WidgetTester tester) async {
    const applicant = Applicant(
      id: 'ravi',
      name: 'Ravi Kumar',
      initials: 'RK',
      avatarAsset: 'assets/images/ravi_profile.png',
      role: 'Consistent household finances',
      summary: 'Strong evidence',
      evidenceLabel: 'High evidence',
      evidenceValue: .94,
      pathway: AssessmentPathway.trustScore,
      records: [],
      positiveFactors: [],
      negativeFactors: [],
    );

    await tester.pumpWidget(const OpenCredApp(applicants: [applicant]));
    await tester.tap(find.text('Start demonstration'));
    await tester.pump();
    await tester.tap(find.text('Continue demo journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('National ID verification'));
    await tester.pump();
    await tester.tap(find.text('Consent and permissions'));
    await tester.pump();
    await tester.tap(find.text('AI assessment'));
    await tester.pump();
    await tester.ensureVisible(find.text('Open assessment'));
    await tester.tap(find.text('Open assessment'));
    await tester.pumpAndSettle();

    expect(find.text('AI assessment'), findsOneWidget);
  });
}
