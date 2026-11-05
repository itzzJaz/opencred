import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), children: [
    Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('Demo controls and product information.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 22),
    Card(child: Column(children: [
      ListTile(leading: const Icon(Icons.science_outlined), title: const Text('Judge Demo Mode'), subtitle: const Text('Offline, fictional applicants and bundled CSV records'), trailing: Switch(value: true, onChanged: null)),
      const Divider(height: 1), ListTile(leading: const Icon(Icons.restart_alt), title: const Text('Reset demonstration'), subtitle: const Text('Return to Ravi and clear journey progress'), onTap: state.reset),
    ])),
    const SizedBox(height: 20),
    const SectionTitle('About TrustScore'),
    const Disclosure(title: 'Trust Beyond Credit History.', body: 'TrustScore explores transparent financial-behaviour evidence beyond conventional credit history. It is a demonstration, not a live financial service.'),
    const SizedBox(height: 16),
    const Disclosure(title: 'What is implemented here?', body: 'Synthetic applicant profiles, simulated verification, consent states, CSV-backed records, a modular mock assessment service, institution review and an assistance application form.'),
    const SizedBox(height: 16),
    const Disclosure(title: 'What comes later?', body: 'A FastAPI backend, approved data providers, a separately validated ML engine, country-specific review and production governance.'),
  ]);
}
