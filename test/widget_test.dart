import 'package:flutter/material.dart';
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

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsWidgets);
    expect(find.byTooltip('Switch profile'), findsOneWidget);
  });

  testWidgets('opens assessment after completing the journey',
      (WidgetTester tester) async {
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
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue application'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Identity check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Consent').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assessment').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open assessment'));
    await tester.pumpAndSettle();

    expect(find.text('Assessment'), findsWidgets);
  });

  testWidgets('profile switcher provides a bounded searchable list',
      (WidgetTester tester) async {
    const first = Applicant(
      id: 'TS-1000',
      name: 'Applicant TS-1000',
      initials: '00',
      avatarAsset: 'assets/images/trustscore_icon.jpg',
      role: 'Synthetic evidence available',
      summary: 'Synthetic profile',
      evidenceLabel: 'Sufficient evidence',
      evidenceValue: 1,
      pathway: AssessmentPathway.trustScore,
      records: [],
      positiveFactors: [],
      negativeFactors: [],
    );
    final applicants = List.generate(
      60,
      (index) => Applicant(
        id: 'TS-${1000 + index}',
        name: 'Applicant TS-${1000 + index}',
        initials: 'AP',
        avatarAsset: 'assets/images/trustscore_icon.jpg',
        role: 'Synthetic evidence available',
        summary: 'Synthetic profile',
        evidenceLabel: 'Sufficient evidence',
        evidenceValue: 1,
        pathway: AssessmentPathway.trustScore,
        records: const [],
        positiveFactors: const [],
        negativeFactors: const [],
      ),
    );

    await tester.pumpWidget(OpenCredApp(applicants: [first, ...applicants]));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch profile'));
    await tester.pumpAndSettle();

    expect(find.text('61 profiles'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Applicant TS-1000'), findsWidgets);

    await tester.enterText(find.byType(TextField), '1059');
    await tester.pump();
    expect(find.text('Applicant TS-1059'), findsOneWidget);
  });
}
