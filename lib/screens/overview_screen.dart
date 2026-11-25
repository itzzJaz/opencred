import 'package:flutter/material.dart';

import '../app.dart';
import '../app_theme.dart';
import '../models.dart';
import '../motion_widgets.dart';
import '../three_d_stage.dart';
import '../widgets.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.state, super.key});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return ScrollRevealList(
      padding: const EdgeInsets.fromLTRB(
        Layout.pageGutter,
        Spacing.lg,
        Layout.pageGutter,
        Layout.pageBottomInset,
      ),
      children: [
        const PageHeader(
          title: 'Overview',
          subtitle: 'Profile, progress and application',
        ),
        _StatementCard(state: state),
        const SizedBox(height: Spacing.sm),
        const SeamlessContinuousMarquee(
          text: 'NO POVERTY — TRUST BEYOND CREDIT HISTORY',
          height: 52,
          velocity: 22,
          backgroundColor: Color(0xFFE10600),
          accentColor: Color(0xFFF4F3EF),
        ),
        const SizedBox(height: Spacing.lg),
        _ScoreCard(state: state),
        const SizedBox(height: Spacing.lg),
        const SectionHeader(title: 'Progress'),
        _JourneyCard(state: state),
        const SizedBox(height: Spacing.lg),
        const SectionHeader(title: 'Application'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: palette.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.applicationStatus,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        'Additional information may be requested',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: palette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg + 6, Spacing.lg, Spacing.lg, Spacing.lg),
      decoration: BoxDecoration(
        color: palette.hero,
        border: Border(
          top: BorderSide(color: palette.hairline),
          right: BorderSide(color: palette.hairline),
          bottom: BorderSide(color: palette.hairline),
          left: BorderSide(color: palette.accent, width: 5),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -24,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -.12,
                child: Text(
                  'SDG1',
                  style: TextStyle(
                    fontFamily: 'BarlowCondensed',
                    fontSize: 128,
                    height: .8,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -8,
                    color: palette.onHero.withValues(alpha: .055),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UN SDG 1  ·  NO POVERTY',
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                  color: palette.onHero.withValues(alpha: .72),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'BarlowCondensed',
                    fontSize: MediaQuery.sizeOf(context).width < 360 ? 36 : 42,
                    height: .94,
                    letterSpacing: -.5,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: palette.onHero,
                  ),
                  children: [
                    const TextSpan(text: 'TRUST BEYOND\n'),
                    TextSpan(
                      text: 'CREDIT HISTORY.',
                      style: TextStyle(color: palette.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Evidence, consent and model output in one view.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: palette.onHero.withValues(alpha: .72),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              JourneyButton(state: state, onHero: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// The numeric TrustScore on the overview. The wheel lives on the assessment
/// screen; here the number is the whole point.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final score = state.selected.trustScore;
    final band = score == null ? null : scoreBand(palette, score);
    final bandName = band?.$1;
    final label = bandName == null
        ? 'TrustScore not scored. Add evidence.'
        : 'TrustScore $score out of 1000, $bandName. Open assessment.';

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => state.setTab(1),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TrustScore',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: palette.secondary,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        if (score == null)
                          Text(
                            'Not scored',
                            style: TextStyle(
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              TweenAnimationBuilder<double>(
                                key: ValueKey(state.selected.id),
                                tween: Tween(begin: 0, end: score.toDouble()),
                                duration: const Duration(milliseconds: 680),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) => Text(
                                  value.round().toString(),
                                  style: TextStyle(
                                    fontSize: 38,
                                    height: 1,
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w600,
                                    color: palette.ink,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: Spacing.xxs),
                              Text(
                                '/ 1000',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.2,
                                  color: palette.muted,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: Spacing.xxs),
                        if (band != null)
                          StatusLabel(band.$1, color: band.$2)
                        else
                          StatusLabel('Needs evidence', color: palette.warning),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: ThreeDStage(
                      style: ThreeDStageStyle.scoreOrb,
                      identity: state.selected.id,
                      accent: palette.accent,
                      surface: palette.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Identity check', state.identityVerified),
      ('Consent', state.consentGranted),
      ('Assessment', state.assessmentStarted),
    ];
    final currentIndex = steps.indexWhere((step) => !step.$2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    _JourneyStepCard(
                      index: i,
                      title: steps[i].$1,
                      done: steps[i].$2,
                      current: i == currentIndex,
                    ),
                    if (i < steps.length - 1)
                      const SizedBox(width: Spacing.xxs),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            KineticProgressBar(
              value: steps.where((step) => step.$2).length / steps.length,
              height: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({
    required this.index,
    required this.title,
    required this.done,
    required this.current,
  });

  final int index;
  final String title;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final foreground = current ? palette.onAccent : palette.ink;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: const Cubic(.2, .8, .2, 1),
      width: 148,
      height: 126,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: current ? palette.accent : palette.surface,
        border: Border.all(
          color: current ? palette.accent : palette.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontStyle: FontStyle.italic,
                  fontSize: 42,
                  height: .85,
                  fontWeight: FontWeight.w900,
                  color: current
                      ? palette.onAccent.withValues(alpha: .45)
                      : palette.accent.withValues(alpha: .68),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Icon(
                done ? Icons.check : Icons.arrow_forward,
                size: 16,
                color: foreground.withValues(alpha: .75),
              ),
            ],
          ),
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'BarlowCondensed',
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: foreground,
            ),
          ),
          Text(
            done
                ? 'COMPLETE'
                : current
                    ? 'CURRENT'
                    : 'PENDING',
            style: TextStyle(
              fontFamily: 'BarlowCondensed',
              fontSize: 11,
              letterSpacing: .7,
              fontWeight: FontWeight.w500,
              color: foreground.withValues(alpha: .72),
            ),
          ),
        ],
      ),
    );
  }
}
