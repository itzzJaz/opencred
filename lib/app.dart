import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'demo_repository.dart';
import 'liquid_glass.dart';
import 'judge_lens.dart';
import 'motion_widgets.dart';
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
  late final DemoState state = DemoState(
    widget.applicants,
    assessor: DemoRepository.assess,
  );
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
          home: EditorialPreloader(
            child: state.showWelcome
                ? WelcomeScreen(state: state)
                : _Shell(state: state),
          ),
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
                if (state.judgeLensEnabled) const JudgeLensPanel(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final isIncoming = (child.key as ValueKey<int>?)?.value ==
                          state.tabIndex;
                      if (!isIncoming) {
                        return FadeTransition(opacity: animation, child: child);
                      }
                      final entrance = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return Stack(
                        children: [
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.16, 1,
                                  curve: Curves.easeOut),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.025, 0),
                                end: Offset.zero,
                              ).animate(entrance),
                              child: child,
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: animation,
                                builder: (context, _) {
                                  final progress = animation.value;
                                  if (progress <= 0 || progress >= 1) {
                                    return const SizedBox.shrink();
                                  }
                                  return CustomPaint(
                                    painter: LeclercShutterBandPainter(
                                      progress: progress,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                  onSelected: (index) {
                    HapticFeedback.selectionClick();
                    state.setTab(index);
                  },
                ),
              ),
            ),
            if (state.profileSwitching && state.profileSwitchFrom != null)
              Positioned.fill(
                child: _ProfileHandoff(
                  from: state.profileSwitchFrom!,
                  to: state.selected,
                  onDismiss: state.dismissProfileSwitch,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHandoff extends StatefulWidget {
  const _ProfileHandoff({
    required this.from,
    required this.to,
    required this.onDismiss,
  });

  final Applicant from;
  final Applicant to;
  final VoidCallback onDismiss;

  @override
  State<_ProfileHandoff> createState() => _ProfileHandoffState();
}

class _ProfileHandoffState extends State<_ProfileHandoff>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1650),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final oldExit = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.42, curve: Curves.easeInCubic),
    );
    final newEntrance = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.39, 0.84, curve: Curves.easeOutBack),
    );
    final sweep = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final impactFlash = const Interval(0.36, 0.52, curve: Curves.easeOut)
        .transform(_controller.value);
    final flashStrength = .55 * (1 - (2 * impactFlash - 1).abs());

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _ProfileAtmospherePainter(
                progress: _controller.value,
                base: palette.hero,
                accent: palette.accent,
              ),
              child: const SizedBox.expand(),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: widget.onDismiss,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close'),
                  style: TextButton.styleFrom(foregroundColor: palette.onHero),
                ),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (1 - oldExit.value).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(-18 * oldExit.value,
                          -screenHeight * .82 * oldExit.value),
                      child: Transform.rotate(
                        angle: -.045 * oldExit.value,
                        child: Transform.scale(
                          scale: 1 + .85 * oldExit.value,
                          child: _HandoffIdentity(
                            applicant: widget.from,
                            palette: palette,
                            kicker: 'LEAVING PROFILE',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: newEntrance.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(16 * (1 - newEntrance.value),
                          screenHeight * .72 * (1 - newEntrance.value)),
                      child: Transform.rotate(
                        angle: .08 * (1 - newEntrance.value),
                        child: Transform.scale(
                          scale: .42 + .58 * newEntrance.value,
                          child: _HandoffIdentity(
                            applicant: widget.to,
                            palette: palette,
                            kicker: 'NOW VIEWING',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (impactFlash > 0)
              IgnorePointer(
                child: ColoredBox(
                  color: palette.accent.withValues(
                    alpha: flashStrength,
                  ),
                ),
              ),
            Positioned(
              left: sweep * (_controller.value * 1.5 - .5),
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Container(
                    width: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          palette.accent.withValues(alpha: .72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandoffIdentity extends StatelessWidget {
  const _HandoffIdentity({
    required this.applicant,
    required this.palette,
    required this.kicker,
  });

  final Applicant applicant;
  final Palette palette;
  final String kicker;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            kicker,
            style: TextStyle(
              color: palette.onHero.withValues(alpha: .68),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          ApplicantAvatar(applicant: applicant, size: 168),
          const SizedBox(height: Spacing.lg),
          Text(
            applicant.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.onHero,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            applicant.id,
            style: TextStyle(color: palette.onHero.withValues(alpha: .65)),
          ),
        ],
      );
}

class _ProfileAtmospherePainter extends CustomPainter {
  const _ProfileAtmospherePainter({
    required this.progress,
    required this.base,
    required this.accent,
  });

  final double progress;
  final Color base;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: .22),
            base,
            const Color(0xFF07090D)
          ],
          stops: const [0, .48, 1],
        ).createShader(rect),
    );

    final horizon = size.height * (.72 - .035 * (1 - progress));
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * .5, horizon),
      radius: size.width * .48,
    );
    canvas.drawCircle(
      glowRect.center,
      glowRect.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: .30), Colors.transparent],
        ).createShader(glowRect),
    );

    final skyline = Paint()
      ..color = const Color(0xFF080A0E).withValues(alpha: .78);
    const heights = [.12, .2, .16, .28, .18, .24, .14, .22, .17];
    final drift = (1 - progress) * size.width * .045;
    for (var i = 0; i < heights.length; i++) {
      final x = i * size.width / 8 - size.width / 16 + drift;
      final width = size.width / 9;
      final height = size.height * heights[i];
      canvas.drawRect(
        Rect.fromLTWH(x, horizon - height, width, height),
        skyline,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      skyline,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.base != base ||
      oldDelegate.accent != accent;
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
      child: Row(
        children: [
          Expanded(
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
                          Icon(Icons.unfold_more,
                              size: 16, color: palette.muted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Tooltip(
            message: state.judgeLensEnabled
                ? 'Hide implementation status badges'
                : 'Show implementation status badges',
            child: TextButton.icon(
              onPressed: state.toggleJudgeLens,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                minimumSize: const Size(0, 38),
                foregroundColor:
                    state.judgeLensEnabled ? palette.ink : palette.secondary,
              ),
              icon: Icon(
                state.judgeLensEnabled
                    ? Icons.visibility
                    : Icons.visibility_outlined,
                size: 16,
              ),
              label: const Text(
                'Judge Lens',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
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
