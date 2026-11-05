import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';
import 'widgets.dart';
import 'screens/overview_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/assistance_screen.dart';
import 'screens/institution_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';

class OpenCredApp extends StatefulWidget {
  const OpenCredApp({required this.applicants, super.key});
  final List<Applicant> applicants;
  @override
  State<OpenCredApp> createState() => _OpenCredAppState();
}

class _OpenCredAppState extends State<OpenCredApp> {
  late final DemoState state = DemoState(widget.applicants);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => MaterialApp(
      title: 'TrustScore',
      debugShowCheckedModeBanner: false,
      theme: OpenCredTheme.light(),
      home: state.showWelcome ? WelcomeScreen(state: state) : _Shell(state: state),
    ),
  );
}

class _Shell extends StatelessWidget {
  const _Shell({required this.state});
  final DemoState state;

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Overview'),
    NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Assessment'),
    NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Assistance'),
    NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Institution'),
    NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(state: state),
      AssessmentScreen(state: state),
      AssistanceScreen(state: state),
      InstitutionScreen(state: state),
      SettingsScreen(state: state),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProfileSwitcher(state: state),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(.03, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(state.tabIndex), child: screens[state.tabIndex]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tabIndex,
        onDestinationSelected: state.setTab,
        destinations: destinations,
        height: 74,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
    );
  }
}

class _ProfileSwitcher extends StatelessWidget {
  const _ProfileSwitcher({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
    child: Row(
      children: [
        Tooltip(
          message: 'Switch profile',
          child: InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => _showProfiles(context),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: OpenCredTheme.ink,
                backgroundImage: AssetImage(state.selected.avatarAsset),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current profile', style: TextStyle(color: Colors.brown[400], fontSize: 11, fontWeight: FontWeight.w600)),
            Text(state.selected.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Open settings',
          onPressed: () => state.setTab(4),
          icon: const Icon(Icons.tune),
        ),
      ],
    ),
  );

  void _showProfiles(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Switch profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Choose a fictional applicant for this demonstration.'),
            const SizedBox(height: 14),
            for (final applicant in state.applicants)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ApplicantAvatar(applicant: applicant, size: 42),
                title: Text(applicant.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(applicant.role),
                trailing: state.selected.id == applicant.id
                    ? const Icon(Icons.check_circle, color: OpenCredTheme.green)
                    : const Icon(Icons.chevron_right),
                onTap: () {
                  state.selectApplicant(applicant);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class JourneyButton extends StatelessWidget {
  const JourneyButton({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _JourneySheet(state: state),
    ),
    icon: const Icon(Icons.play_arrow_rounded), label: const Text('Continue demo journey'),
  );
}

class _JourneySheet extends StatelessWidget {
  const _JourneySheet({required this.state});
  final DemoState state;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Applicant journey', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8), const Text('Every step is simulated for this offline demonstration.'),
      const SizedBox(height: 20),
      ListTile(
        leading: const Icon(Icons.badge_outlined), title: const Text('National ID verification'),
        subtitle: const Text('Simulated integration'), trailing: StatusPill(state.identityVerified ? 'Verified' : 'Ready'),
        onTap: state.verifyIdentity,
      ),
      ListTile(
        leading: const Icon(Icons.lock_outline), title: const Text('Consent and permissions'),
        subtitle: const Text('Review data categories'), trailing: StatusPill(state.consentGranted ? 'Granted' : 'Review'),
        onTap: state.identityVerified ? state.grantConsent : null,
      ),
      ListTile(
        leading: const Icon(Icons.auto_awesome), title: const Text('AI assessment'),
        trailing: StatusPill(state.assessmentStarted ? 'Viewed' : 'Pending'),
        onTap: state.consentGranted ? state.startAssessment : null,
      ),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) => state.setTab(1));
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Open assessment'),
      )),
      ]),
    ),
  );
}
