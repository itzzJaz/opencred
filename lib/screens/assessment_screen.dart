import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

/// The six fields the bundled model reads, in plain language. Missing values
/// stay visible: an evidence gap is the point of the alternative pathway.
const _evidenceFields = [
  ('utility_payment_consistency_pct', 'Utility payments'),
  ('rent_payment_reliability_pct', 'Rent reliability'),
  ('verified_income_regularity_pct', 'Verified income'),
  ('previous_loan_repayment_history', 'Previous loans'),
  ('missed_payments_count_12m', 'Missed payments'),
  ('existing_financial_obligations_ratio', 'Obligation ratio'),
];

String _formatEvidence(String key, double value) {
  if (key.endsWith('_ratio')) return '${(value * 100).round()}%';
  if (key.endsWith('_pct')) return '${value.round()}%';
  return '${value.round()}';
}

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({required this.state, super.key});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Layout.pageGutter,
        Spacing.lg,
        Layout.pageGutter,
        Layout.pageBottomInset,
      ),
      children: [
        const PageHeader(
          title: 'Assessment',
          subtitle: 'Evidence and outcome',
        ),
        _EvidenceCard(state: state),
        const SizedBox(height: Spacing.md),
        ...(state.selected.hasScore
            ? [_TrustScoreCard(applicant: state.selected)]
            : [_AlternativeCard(applicant: state.selected)]),
      ],
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final applicant = state.selected;
    final complete = applicant.evidenceValue >= .8;
    final percent = '${(applicant.evidenceValue * 100).round()}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ApplicantAvatar(applicant: applicant, size: 40),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MetaText(applicant.role),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Evidence sufficiency',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: palette.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  percent,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.xxs),
              child: LinearProgressIndicator(
                value: applicant.evidenceValue,
                minHeight: Spacing.xs,
                color: complete ? palette.positive : palette.warning,
                backgroundColor: palette.raised,
              ),
            ),
            const SizedBox(height: Spacing.md),
            for (final field in _evidenceFields)
              EvidenceRow(
                label: field.$2,
                state: applicant.evidence?[field.$1] == null
                    ? 'Missing'
                    : _formatEvidence(field.$1, applicant.evidence![field.$1]!),
                complete: applicant.evidence?[field.$1] != null,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrustScoreCard extends StatelessWidget {
  const _TrustScoreCard({required this.applicant});
  final Applicant applicant;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final score = applicant.trustScore;
    if (score == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg),
          child: Text('No model result for this profile.'),
        ),
      );
    }
    final band = scoreBand(palette, score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'TrustScore',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                StatusLabel(band.$1, color: band.$2),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Center(child: _TrustScoreGauge(score: score)),
            const SizedBox(height: Spacing.lg),
            Divider(color: palette.hairline),
            const SizedBox(height: Spacing.md),
            Text(
              'Key factors',
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            for (final factor in applicant.positiveFactors)
              _FactorRow(label: factor, positive: true),
            for (final factor in applicant.negativeFactors)
              _FactorRow(label: factor, positive: false),
          ],
        ),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.label, required this.positive});
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: positive ? palette.positive : palette.negative,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustScoreGauge extends StatefulWidget {
  const _TrustScoreGauge({required this.score});
  final int score;

  @override
  State<_TrustScoreGauge> createState() => _TrustScoreGaugeState();
}

class _TrustScoreGaugeState extends State<_TrustScoreGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> scoreAnimation;
  bool started = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    scoreAnimation = _animationFor(widget.score);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _TrustScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      scoreAnimation = _animationFor(widget.score);
      controller
        ..reset()
        ..forward();
    }
  }

  Animation<double> _animationFor(int score) =>
      Tween<double>(begin: 0, end: score.toDouble()).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return AnimatedBuilder(
      animation: scoreAnimation,
      builder: (context, _) {
        final progress = (scoreAnimation.value / 1000).clamp(0.0, 1.0);
        return SizedBox(
          width: 236,
          height: 236,
          child: CustomPaint(
            painter: _ScoreGaugePainter(
              progress: progress,
              color: palette.accent,
              track: palette.raised,
              surface: palette.surface,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scoreAnimation.value.round().toString(),
                    style: TextStyle(
                      fontSize: 56,
                      height: 1,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'out of 1000',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  const _ScoreGaugePainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.surface,
  });

  final double progress;
  final Color color;
  final Color track;
  final Color surface;

  static const double _stroke = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final background = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, background);
    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);

    // A marker sits on the leading edge of the arc so the count-up has a
    // physical anchor. It is the only gold object on the screen.
    final tip = Offset(
      center.dx + radius * math.cos(-math.pi / 2 + sweep),
      center.dy + radius * math.sin(-math.pi / 2 + sweep),
    );
    canvas.drawCircle(tip, _stroke / 2 + 3, Paint()..color = surface);
    canvas.drawCircle(tip, _stroke / 2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.surface != surface;
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.applicant});
  final Applicant applicant;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    const steps = [
      'Add documented informal income',
      'Provide cooperative or repayment evidence',
      'Request an assisted human review',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusLabel('Needs more evidence', color: palette.warning),
            const SizedBox(height: Spacing.sm),
            Text(
              'No score for this profile',
              style: TextStyle(
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'The records available are not sufficient for a fair score.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: palette.secondary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Next steps',
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            for (final step in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: palette.muted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
