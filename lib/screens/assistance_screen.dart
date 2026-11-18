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
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Layout.pageGutter,
        Spacing.lg,
        Layout.pageGutter,
        Layout.pageBottomInset,
      ),
      children: [
        const PageHeader(
          title: 'Assistance',
          subtitle: 'Support programme application',
        ),
        if (submitted)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: palette.positive,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Application received. A programme administrator will review it.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    _field('Applicant name', widget.state.selected.name),
                    const SizedBox(height: Spacing.md),
                    _field(
                      'Household monthly income',
                      '',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: Spacing.md),
                    _field(
                      'Monthly essential expenses',
                      '',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: Spacing.md),
                    _field(
                      'Requested support amount',
                      '',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: Spacing.md),
                    _field('Reason for assistance', '', maxLines: 3),
                    const SizedBox(height: Spacing.md),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 18,
                            color: palette.muted,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Supporting documentation',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
                                    color: palette.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const MetaText('Optional'),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() => submitted = true);
              }
            },
            child: const Text('Submit application'),
          ),
        ],
      ],
    );
  }

  Widget _field(
    String label,
    String initial, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) =>
      TextFormField(
        initialValue: initial,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
      );
}
