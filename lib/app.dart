import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'liquid_glass.dart';
import 'models.dart';
import 'widgets.dart';
import 'screens/overview_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/assistance_screen.dart';
import 'screens/create_applicant_screen.dart';
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
          darkTheme: OpenCredTheme.dark(),
          themeMode: state.themeMode,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: child ?? const SizedBox.shrink(),
          ),
          home: state.showWelcome
              ? WelcomeScreen(state: state)
              : _Shell(state: state),
        ),
      );
}

class _Shell extends StatelessWidget {
  const _Shell({required this.state});
  final DemoState state;

  static const destinations = [
    GlassNavDestination(
        icon: Icons.space_dashboard_outlined, label: 'Overview'),
    GlassNavDestination(icon: Icons.fact_check_outlined, label: 'Assess'),
    GlassNavDestination(
        icon: Icons.volunteer_activism_outlined, label: 'Support'),
    GlassNavDestination(icon: Icons.account_balance_outlined, label: 'Review'),
    GlassNavDestination(icon: Icons.settings_outlined, label: 'Settings'),
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
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _ProfileBar(state: state),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, .015), end: Offset.zero)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(state.tabIndex),
                      child: screens[state.tabIndex],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: Spacing.md,
              right: Spacing.md,
              bottom: Spacing.md,
              child: SafeArea(
                top: false,
                child: GlassNavBar(
                  destinations: destinations,
                  selectedIndex: state.tabIndex,
                  onSelected: state.setTab,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBar extends StatelessWidget {
  const _ProfileBar({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.xs,
        Spacing.md,
        Spacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          button: true,
          label: 'Switch profile, ${state.selected.name}',
          child: Tooltip(
            message: 'Switch profile',
            child: LiquidGlassSurface(
              capsule: true,
              elevated: false,
              tint: palette.raised.withValues(alpha: 0.72),
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.xxs,
                Spacing.sm,
                Spacing.xxs,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.capsule),
                onTap: () => _showProfiles(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ApplicantAvatar(applicant: state.selected, size: 32),
                    const SizedBox(width: Spacing.xs),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: palette.muted,
                            ),
                          ),
                          Text(
                            state.selected.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Icon(Icons.unfold_more, size: 16, color: palette.muted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProfiles(BuildContext context) => showGlassSheet<void>(
        context: context,
        heightFactor: .84,
        builder: (context) => _ProfileSheet(state: state),
      );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.state});
  final DemoState state;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final searchController = TextEditingController();
  String query = '';
  bool? scored;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final theme = Theme.of(context);
    final normalized = query.trim().toLowerCase();
    final profiles = widget.state.applicants.where((applicant) {
      final matchesQuery = normalized.isEmpty ||
          applicant.id.toLowerCase().contains(normalized) ||
          applicant.name.toLowerCase().contains(normalized);
      final matchesFilter = scored == null || applicant.hasScore == scored;
      return matchesQuery && matchesFilter;
    }).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xs, Spacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text('Switch profile', style: theme.textTheme.titleLarge),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                constraints:
                    const BoxConstraints.tightFor(width: 40, height: 40),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xxs),
          MetaText('${widget.state.applicants.length} profiles'),
          const SizedBox(height: Spacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(Radii.row),
            onTap: () => _openCreate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.surface,
                      border: Border.all(color: palette.hairline),
                    ),
                    child: Icon(Icons.add, size: 18, color: palette.ink),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create profile',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const MetaText('Enter evidence and generate a score'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.xxs),
            decoration: BoxDecoration(
              color: palette.raised,
              borderRadius: BorderRadius.circular(Radii.capsule),
              border: Border.all(color: palette.hairline),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassPill(
                    label: 'All',
                    selected: scored == null,
                    onTap: () => setState(() => scored = null),
                  ),
                  GlassPill(
                    label: 'Scored',
                    selected: scored == true,
                    onTap: () => setState(() => scored = true),
                  ),
                  GlassPill(
                    label: 'Alternative',
                    selected: scored == false,
                    onTap: () => setState(() => scored = false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        searchController.clear();
                        setState(() => query = '');
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: profiles.isEmpty
                ? Center(
                    child: Text(
                      'No profiles match this search',
                      style: TextStyle(color: palette.secondary, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    itemCount: profiles.length,
                    itemExtent: 56,
                    itemBuilder: (context, index) {
                      final applicant = profiles[index];
                      final selected = widget.state.selected.id == applicant.id;
                      return InkWell(
                        borderRadius: BorderRadius.circular(Radii.row),
                        onTap: () {
                          widget.state.selectApplicant(applicant);
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            ApplicantAvatar(applicant: applicant, size: 36),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    applicant.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.3,
                                      fontWeight: FontWeight.w600,
                                      color: palette.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  MetaText(
                                      '${applicant.id} · ${applicant.role}'),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check,
                                size: 18,
                                color: palette.accent,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openCreate(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => CreateApplicantScreen(state: widget.state),
        ),
      );
    });
  }
}

/// The single primary action on the overview statement card.
class JourneyButton extends StatelessWidget {
  const JourneyButton({required this.state, this.onHero = false, super.key});
  final DemoState state;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return FilledButton.icon(
      onPressed: () => showGlassSheet<void>(
        context: context,
        heightFactor: .8,
        builder: (context) => _JourneySheet(state: state),
      ),
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: const Text('Continue application'),
      style: onHero
          ? FilledButton.styleFrom(
              backgroundColor: palette.onHero,
              foregroundColor: palette.hero,
            )
          : null,
    );
  }
}

class _JourneySheet extends StatelessWidget {
  const _JourneySheet({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xs,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application progress', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.lg),
            _JourneyStep(
              icon: Icons.badge_outlined,
              title: 'Identity check',
              state: state.identityVerified ? 'Verified' : 'Ready',
              done: state.identityVerified,
              onTap: state.verifyIdentity,
            ),
            _JourneyStep(
              icon: Icons.lock_outline,
              title: 'Consent',
              state: state.consentGranted ? 'Granted' : 'Review',
              done: state.consentGranted,
              onTap: state.identityVerified ? state.grantConsent : null,
            ),
            _JourneyStep(
              icon: Icons.fact_check_outlined,
              title: 'Assessment',
              state: state.assessmentStarted ? 'Viewed' : 'Pending',
              done: state.assessmentStarted,
              onTap: state.consentGranted ? state.startAssessment : null,
            ),
            const SizedBox(height: Spacing.md),
            const Divider(),
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => state.setTab(1));
                },
                child: const Text('Open assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.icon,
    required this.title,
    required this.state,
    required this.done,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String state;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final enabled = onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.field),
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: enabled ? palette.muted : palette.hairline,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: enabled ? palette.ink : palette.muted,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            StatusLabel(
              state,
              color: done ? palette.positive : palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}
