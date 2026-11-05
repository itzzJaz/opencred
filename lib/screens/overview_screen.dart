import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';
import '../app.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 32), children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('OPENCRED', style: TextStyle(letterSpacing: 2, color: Colors.grey[600], fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 4), Text('Good morning', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    const SizedBox(height: 24),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: OpenCredTheme.ink, borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StatusPill('JUDGE DEMO MODE', color: Colors.white),
        const SizedBox(height: 20),
        const Text('Trust beyond\ncredit history.', style: TextStyle(color: Colors.white, fontSize: 32, height: 1.05, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12), Text('A responsible, explainable view of financial behaviour.', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 22), JourneyButton(state: state),
      ]),
    ),
    const SizedBox(height: 28),
    SectionTitle('Journey status'),
    _ProgressCard(state: state),
    const SizedBox(height: 24),
    const Disclosure(title: 'Responsible by design', body: 'TrustScore is supplementary information. Institutions remain responsible for affordability, lending and compliance decisions.'),
    const SizedBox(height: 24),
    SectionTitle('Application status'),
    Card(child: ListTile(
      leading: const Icon(Icons.timelapse, color: OpenCredTheme.blue),
      title: const Text('Under review', style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle: const Text('Simulated status · additional information may be requested'),
      trailing: const Icon(Icons.chevron_right),
    )),
  ]);
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});
  final DemoState state;
  @override
  Widget build(BuildContext context) {
    final steps = [('Identity', state.identityVerified), ('Consent', state.consentGranted), ('Assessment', state.assessmentStarted)];
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      for (var i = 0; i < steps.length; i++) ...[
        Row(children: [
          CircleAvatar(radius: 13, backgroundColor: steps[i].$2 ? OpenCredTheme.green : Colors.grey[200],
            child: Icon(steps[i].$2 ? Icons.check : Icons.circle, size: 14, color: steps[i].$2 ? Colors.white : Colors.grey[500])),
          const SizedBox(width: 12),
          Expanded(child: Text(steps[i].$1, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Flexible(child: Align(
            alignment: Alignment.centerRight,
            child: Text(steps[i].$2 ? 'Complete' : 'Next', overflow: TextOverflow.ellipsis,
              style: TextStyle(color: steps[i].$2 ? OpenCredTheme.green : Colors.grey[600], fontSize: 12)),
          )),
        ]),
        if (i < steps.length - 1) const SizedBox(height: 14),
      ],
    ])));
  }
}
