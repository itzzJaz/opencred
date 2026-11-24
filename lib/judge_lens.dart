import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Compact feature-status legend shown when Judge Lens is enabled.
class JudgeLensPanel extends StatelessWidget {
  const JudgeLensPanel({super.key});

  static const modules = [
    ('Ollama Scoring', 'IMPLEMENTED'),
    ('National ID', 'SIMULATED'),
    ('CSV Financial Data', 'SIMULATED'),
    ('Live Bank Integrations', 'FUTURE'),
    ('Regulatory Integrations', 'FUTURE'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: palette.raised.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(Radii.row),
        border: Border.all(color: palette.hairline),
      ),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.xs,
        children: [
          for (final module in modules)
            _ModuleStatus(label: module.$1, status: module.$2),
        ],
      ),
    );
  }
}

class _ModuleStatus extends StatelessWidget {
  const _ModuleStatus({required this.label, required this.status});
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final color = switch (status) {
      'IMPLEMENTED' => palette.positive,
      'SIMULATED' => palette.warning,
      _ => palette.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.row),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(color: palette.secondary),
            ),
            TextSpan(
              text: status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 10.5, height: 1.2),
      ),
    );
  }
}
