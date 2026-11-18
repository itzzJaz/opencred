import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class InstitutionScreen extends StatelessWidget {
  const InstitutionScreen({required this.state, super.key});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final applicant = state.selected;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Layout.pageGutter,
        Spacing.lg,
        Layout.pageGutter,
        Layout.pageBottomInset,
      ),
      children: [
        const PageHeader(
          title: 'Institution review',
          subtitle: 'Applicant summary',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ApplicantAvatar(applicant: applicant, size: 44),
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
                              fontSize: 17,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          MetaText('${applicant.id} · ${applicant.role}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                const Divider(),
                const SizedBox(height: Spacing.xs),
                MetricRow(
                  label: 'Evidence completeness',
                  value: '${(applicant.evidenceValue * 100).round()}%',
                ),
                MetricRow(
                  label: 'Assessment',
                  value: applicant.hasScore
                      ? '${applicant.trustScore} / 1000'
                      : 'Not scored',
                ),
                const MetricRow(
                  label: 'Assistance application',
                  value: 'Not submitted',
                ),
                const MetricRow(label: 'Human review', value: 'Required'),
                if (applicant.hasScore) ...[
                  const SizedBox(height: Spacing.xs),
                  const Divider(),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Score basis',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: palette.muted,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    _explain(applicant),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: palette.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        const SectionHeader(title: 'Reviewer note'),
        _ReviewerNote(state: state, applicant: applicant),
      ],
    );
  }
}

class _ReviewerNote extends StatefulWidget {
  const _ReviewerNote({required this.state, required this.applicant});
  final DemoState state;
  final Applicant applicant;

  @override
  State<_ReviewerNote> createState() => _ReviewerNoteState();
}

class _ReviewerNoteState extends State<_ReviewerNote> {
  late final TextEditingController controller = TextEditingController(
    text: widget.state.noteFor(widget.applicant.id),
  );

  @override
  void didUpdateWidget(covariant _ReviewerNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.applicant.id != widget.applicant.id) {
      controller.text = widget.state.noteFor(widget.applicant.id);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) =>
              widget.state.setNote(widget.applicant.id, value),
          decoration: const InputDecoration(
            hintText: 'Add context for this applicant',
          ),
        ),
      ),
    );
  }
}

/// The reviewer summary reads as two plain sentences, and the model's
/// fallback labels ("No strong negative indicator available") become human
/// language rather than a status code in a sentence.
String _explain(Applicant applicant) {
  String first(List<String> values, String fallback) =>
      values.isEmpty ? fallback : values.first;
  final positive =
      first(applicant.positiveFactors, 'No strong positive signal was found');
  final negative =
      first(applicant.negativeFactors, 'No strong negative signal was found');
  final resolvedNegative = negative == 'No strong negative indicator available'
      ? 'No strong negative signal was found'
      : negative;
  return '$positive. $resolvedNegative.';
}
