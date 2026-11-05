import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({required this.state, super.key});
  final DemoState state;
  @override
  State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final formKey = GlobalKey<FormState>();
  bool submitted = false;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), children: [
    Text('Interest assistance', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('A separate programme for support, not a lending decision.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 20),
    if (submitted) Card(color: OpenCredTheme.green.withOpacity(.08), child: const Padding(padding: EdgeInsets.all(18), child: Row(children: [
      Icon(Icons.check_circle, color: OpenCredTheme.green), SizedBox(width: 12), Expanded(child: Text('Application submitted for simulated review. Eligibility is not guaranteed.', style: TextStyle(fontWeight: FontWeight.w600))),
    ]))) else Form(key: formKey, child: Column(children: [
      _field('Applicant name', widget.state.selected.name),
      _field('Household monthly income', '', keyboard: TextInputType.number),
      _field('Monthly essential expenses', '', keyboard: TextInputType.number),
      _field('Requested support amount', '', keyboard: TextInputType.number),
      _field('Reason for assistance', '', maxLines: 3),
      Card(child: ListTile(leading: const Icon(Icons.attach_file), title: const Text('Supporting documentation'), subtitle: const Text('Optional in this offline demo'), trailing: TextButton(onPressed: () {}, child: const Text('Add')))),
      const SizedBox(height: 12), const Disclosure(title: 'Eligibility review', body: 'A future programme administrator would review this separately using transparent local criteria and available funding. No automatic eligibility or guaranteed interest-free financing is promised.'),
      const SizedBox(height: 18), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (formKey.currentState!.validate()) setState(() => submitted = true); }, child: const Text('Submit application'))),
    ])),
  ]);

  Widget _field(String label, String initial, {TextInputType? keyboard, int maxLines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(
    initialValue: initial, keyboardType: keyboard, maxLines: maxLines, validator: (value) => (value == null || value.trim().isEmpty) ? 'Required for this demonstration' : null,
    decoration: InputDecoration(labelText: label),
  ));
}
