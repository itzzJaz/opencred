import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 28), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: OpenCredTheme.ink, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.all_inclusive, color: Colors.white)), const SizedBox(width: 10), const Text('OPENCRED', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800))]),
      const Spacer(),
      const Text('Trust beyond\ncredit history.', style: TextStyle(fontSize: 44, height: 1.03, letterSpacing: -1.5, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      Text('A responsible, explainable view of financial behaviour for people whose story is bigger than a credit file.', style: TextStyle(fontSize: 17, color: Colors.grey[700], height: 1.4)),
      const SizedBox(height: 24),
      const Disclosure(title: 'Offline Judge Demo', body: 'Explore fictional applicants, simulated verification and a mock assessment. No real identity numbers or external services are used.'),
      const Spacer(),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: state.startDemo, child: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Start demonstration')))),
      const SizedBox(height: 12), Center(child: Text('OpenCred · GEMS Innovation Challenge', style: TextStyle(color: Colors.grey, fontSize: 12))),
    ]))),
  );
}
