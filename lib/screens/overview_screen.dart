import 'package:flutter/material.dart';

import '../app.dart';
import '../app_theme.dart';
import '../models.dart';
import '../motion_widgets.dart';
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
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: palette.hero,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: palette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 2,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'See how the score\nwas reached',
            style: TextStyle(
              fontSize: 30,
              height: 1.12,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w600,
              color: palette.onHero,
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
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 40,
                            height: 1,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w600,
                            color: palette.ink,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
      ('Identity', state.identityVerified),
      ('Consent', state.consentGranted),
      ('Assessment', state.assessmentStarted),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _JourneyRow(index: i, title: steps[i].$1, done: steps[i].$2),
              if (i < steps.length - 1) const SizedBox(height: Spacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({
    required this.index,
    required this.title,
    required this.done,
  });

  final int index;
  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: palette.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: palette.ink,
              ),
            ),
          ),
          StatusLabel(
            done ? 'Complete' : 'Next',
            color: done ? palette.positive : palette.muted,
          ),
        ],
      ),
    );
  }
}
