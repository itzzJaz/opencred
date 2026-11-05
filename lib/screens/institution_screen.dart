import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class InstitutionScreen extends StatelessWidget {
  const InstitutionScreen({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Institution review', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const StatusPill('REVIEWER VIEW'),
    ]),
    const SizedBox(height: 8), const Text('Supplementary context for a human reviewer.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 20),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [ApplicantAvatar(applicant: state.selected, size: 46), const SizedBox(width: 12), Expanded(child: Text(state.selected.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18))), StatusPill(state.selected.hasScore ? 'Score available' : 'Alternative path', color: state.selected.hasScore ? OpenCredTheme.green : OpenCredTheme.amber)]),
      const Divider(height: 28),
      _metric('Evidence completeness', '${(state.selected.evidenceValue * 100).round()}%'),
      _metric('Assessment status', state.selected.hasScore ? 'Illustrative score' : 'Additional information required'),
      _metric('Assistance application', 'Not submitted'),
      _metric('Human review', 'Required'),
    ]))),
    const SizedBox(height: 18),
    ...(state.selected.hasScore
        ? [
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome, color: OpenCredTheme.blue),
                title: const Text('AI explanation available'),
                subtitle: Text(
                  'Key signals include ${state.selected.positiveFactors.first.toLowerCase()} and ${state.selected.negativeFactors.first.toLowerCase()}.',
                ),
              ),
            ),
          ]
        : [
            const Disclosure(
              title: 'No score available',
              body: 'The applicant has not been assigned a low score. Review additional evidence or use the assisted-access route.',
            ),
          ]),
    const SizedBox(height: 18),
    const Disclosure(title: 'Institution responsibility', body: 'The institution retains responsibility for affordability checks, eligibility, responsible lending, compliance and the final decision. This demo has no approve or decline control.'),
  ]);

  Widget _metric(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: Colors.grey[600])), Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
  ]));
}
