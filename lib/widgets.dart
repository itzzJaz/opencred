import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models.dart';

/// Page title and one line of context. Every screen starts with this so the
/// first baseline sits at the same height everywhere.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: palette.secondary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Spacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Section label inside a scrolling canvas.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Status as a quiet dot and a short label. This is the app's signature
/// detail: state is never a glowing capsule with uppercase text.
class StatusLabel extends StatelessWidget {
  const StatusLabel(
    this.label, {
    this.color,
    this.showDot = true,
    super.key,
  });

  final String label;
  final Color? color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final resolved = color ?? palette.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: resolved, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.33,
              fontWeight: FontWeight.w500,
              color: resolved,
            ),
          ),
        ),
      ],
    );
  }
}

/// Muted meta line, used for counts, ids and dates.
class MetaText extends StatelessWidget {
  const MetaText(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        height: 1.33,
        color: color ?? palette.muted,
      ),
    );
  }
}

class ApplicantAvatar extends StatelessWidget {
  const ApplicantAvatar({required this.applicant, this.size = 52, super.key});

  final Applicant applicant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.raised,
        border: Border.all(color: palette.hairline),
      ),
      child: ClipOval(
        child: Image.asset(
          applicant.avatarAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Label on the left, value on the right, both on a shared baseline and a
/// shared row height. Values are tabular through the theme. The value keeps
/// its natural width up to 60% of the row, so the label never gets squeezed
/// in half; long labels wrap instead of truncating.
class MetricRow extends StatelessWidget {
  const MetricRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: palette.secondary),
                ),
              ),
              const SizedBox(width: Spacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * .6,
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The score band shared by the overview strip and the assessment card.
(String, Color) scoreBand(Palette palette, int score) {
  if (score >= 700) return ('Strong', palette.positive);
  if (score >= 400) return ('Fair', palette.secondary);
  return ('Developing', palette.warning);
}

/// One row inside an evidence list: signature dot, label, quiet state.
class EvidenceRow extends StatelessWidget {
  const EvidenceRow({
    required this.label,
    required this.state,
    required this.complete,
    super.key,
  });

  final String label;
  final String state;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: complete ? palette.positive : palette.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          MetaText(
            state,
            color: complete ? palette.secondary : palette.warning,
          ),
        ],
      ),
    );
  }
}
