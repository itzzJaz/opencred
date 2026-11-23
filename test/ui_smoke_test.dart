import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/app.dart';
import 'package:opencred/app_theme.dart';
import 'package:opencred/demo_repository.dart';
import 'package:opencred/liquid_glass.dart';
import 'package:opencred/models.dart';
import 'package:opencred/screens/assessment_screen.dart';
import 'package:opencred/screens/assistance_screen.dart';
import 'package:opencred/screens/create_applicant_screen.dart';
import 'package:opencred/screens/institution_screen.dart';
import 'package:opencred/screens/overview_screen.dart';
import 'package:opencred/screens/settings_screen.dart';
import 'package:opencred/screens/welcome_screen.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Applicant> applicants;
  late Applicant scored;
  late Applicant alternative;
  setUpAll(() async {
    applicants = await DemoRepository.loadApplicants();
    scored = applicants.firstWhere((applicant) => applicant.hasScore);
    // The shipped CSV is fully scored, so the alternative pathway is exercised
    // with a fixture rather than by changing the demo data.
    alternative = Applicant(
      id: 'TS-9999',
      name: 'Applicant TS-9999',
      initials: '99',
      avatarAsset: scored.avatarAsset,
      role: 'Evidence still developing',
      summary: 'There is not enough evidence for a fair model assessment.',
      evidenceLabel: 'Insufficient evidence',
      evidenceValue: .5,
      pathway: AssessmentPathway.alternative,
      records: const [],
      positiveFactors: const ['No strong positive indicator available'],
      negativeFactors: const ['No strong negative indicator available'],
      evidence: scored.evidence,
    );
  });

  Future<void> show(
    WidgetTester tester,
    Widget screen,
    Size size,
    Brightness brightness,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.light
            ? OpenCredTheme.light()
            : OpenCredTheme.dark(),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  /// Lazy lists only build what is on screen, so scroll the whole canvas.
  Future<void> scrollThrough(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }

  for (final size in const [Size(390, 844), Size(320, 568)]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'screens render at ${size.width.round()} in ${brightness.name}',
        (tester) async {
          final state = DemoState(applicants)..selectApplicant(scored);
          final alternativeState = DemoState(applicants)
            ..selectApplicant(alternative);

          await show(
            tester,
            WelcomeScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            OverviewScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            AssessmentScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            AssessmentScreen(state: alternativeState),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            AssistanceScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            InstitutionScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            InstitutionScreen(state: alternativeState),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            CreateApplicantScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
          await show(
            tester,
            SettingsScreen(state: state),
            size,
            brightness,
          );
          await scrollThrough(tester);
        },
      );
    }
  }

  testWidgets('nav reaches every destination', (tester) async {
    await show(tester, OpenCredApp(applicants: applicants),
        const Size(390, 844), Brightness.light);
    final start = find.text('Get started');
    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final nav = find.byType(GlassNavBar);
    for (final label in [
      'Assess',
      'Support',
      'Review',
      'Settings',
      'Overview'
    ]) {
      await tester.tap(find.descendant(of: nav, matching: find.text(label)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('profile sheet filters and closes', (tester) async {
    await show(tester, OpenCredApp(applicants: applicants),
        const Size(320, 568), Brightness.light);
    final start = find.text('Get started');
    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Switch profile'), findsOneWidget);

    final alternativePill = find.text('Alternative');
    await tester.ensureVisible(alternativePill);
    await tester.pumpAndSettle();
    await tester.tap(alternativePill);
    await tester.pumpAndSettle();
    expect(find.text('No profiles match this search'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Switch profile'), findsNothing);
  });

  testWidgets('journey sheet advances without overflow', (tester) async {
    final state = DemoState(applicants)..selectApplicant(scored);
    await show(tester, OverviewScreen(state: state), const Size(320, 568),
        Brightness.dark);

    final open = find.text('Continue application');
    await tester.ensureVisible(open);
    await tester.pumpAndSettle();
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.text('Application progress'), findsOneWidget);

    for (final step in ['Identity check', 'Consent', 'Assessment']) {
      await tester.tap(find.text(step).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('assistance form validates', (tester) async {
    final state = DemoState(applicants)..selectApplicant(scored);
    await show(tester, AssistanceScreen(state: state), const Size(320, 568),
        Brightness.light);

    final submit = find.text('Submit application');
    await tester.scrollUntilVisible(
      submit,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('seeded profiles carry distinct real names', () {
    final names = applicants.map((applicant) => applicant.name).toList();
    expect(names.toSet().length, names.length);
    for (final applicant in applicants) {
      expect(applicant.name, isNot(contains('Applicant')));
      expect(applicant.name.split(' ').length, 2);
      expect(applicant.initials.length, 2);
    }
  });

  test('reviewer notes are stored per applicant and cleared by reset', () {
    final state = DemoState(applicants);
    final first = applicants.first;
    final second = applicants[1];

    state.setNote(first.id, 'Verify the income letter');
    expect(state.noteFor(first.id), 'Verify the income letter');
    expect(state.noteFor(second.id), isEmpty);

    state.reset();
    expect(state.noteFor(first.id), isEmpty);
  });

  testWidgets('creates a profile and lands on its assessment', (tester) async {
    await show(tester, OpenCredApp(applicants: applicants),
        const Size(390, 1400), Brightness.light);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create profile'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const ValueKey('create-name')), 'Amina Yusuf');
    await tester.enterText(find.byKey(const ValueKey('create-utility')), '92');
    await tester.enterText(find.byKey(const ValueKey('create-rent')), '88');
    await tester.enterText(find.byKey(const ValueKey('create-income')), '84');
    await tester.enterText(find.byKey(const ValueKey('create-loans')), '12');
    await tester.enterText(find.byKey(const ValueKey('create-missed')), '0');
    await tester.enterText(
        find.byKey(const ValueKey('create-obligations')), '18');

    final submit = find.widgetWithText(FilledButton, 'Create profile');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Evidence sufficiency'), findsOneWidget);
    expect(find.text('Amina Yusuf'), findsWidgets);
    expect(find.textContaining('Amina Yusuf created'), findsOneWidget);
    expect(find.textContaining('out of 1000'), findsOneWidget);
  });

  testWidgets('appearance control switches between themes', (tester) async {
    await show(tester, OpenCredApp(applicants: applicants),
        const Size(390, 844), Brightness.light);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    final nav = find.byType(GlassNavBar);
    await tester.tap(find.descendant(of: nav, matching: find.text('Settings')));
    await tester.pumpAndSettle();

    MaterialApp app() => tester.widget<MaterialApp>(
          find.descendant(
            of: find.byType(OpenCredApp),
            matching: find.byType(MaterialApp),
          ),
        );
    expect(app().themeMode, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Theme'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('Theme'))).brightness,
      Brightness.light,
    );
  });
}
