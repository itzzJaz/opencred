import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../demo_repository.dart';
import '../models.dart';
import '../widgets.dart';

/// A full-screen form that turns six evidence inputs into a scored profile.
///
/// The fields mirror the six features the bundled model reads, so a profile
/// created here goes through exactly the same path as the seeded profiles.
class CreateApplicantScreen extends StatefulWidget {
  const CreateApplicantScreen({required this.state, super.key});
  final DemoState state;

  @override
  State<CreateApplicantScreen> createState() => _CreateApplicantScreenState();
}

class _CreateApplicantScreenState extends State<CreateApplicantScreen> {
  static const _featureCount = 6;

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final utility = TextEditingController();
  final rent = TextEditingController();
  final income = TextEditingController();
  final loans = TextEditingController();
  final missed = TextEditingController();
  final obligations = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    utility.dispose();
    rent.dispose();
    income.dispose();
    loans.dispose();
    missed.dispose();
    obligations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Layout.pageGutter,
              Spacing.xs,
              Layout.pageGutter,
              Spacing.xl,
            ),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed:
                        saving ? null : () => Navigator.of(context).maybePop(),
                    constraints:
                        const BoxConstraints.tightFor(width: 40, height: 40),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xxs),
              Text(
                'Create profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Enter the evidence the model reads. All six fields are required.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: palette.secondary),
              ),
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Applicant'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: TextFormField(
                    key: const ValueKey('create-name'),
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'First and last name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: _required,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Payment behaviour'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    children: [
                      _percentField(
                        key: const ValueKey('create-utility'),
                        controller: utility,
                        label: 'Utility payments',
                      ),
                      const SizedBox(height: Spacing.md),
                      _percentField(
                        key: const ValueKey('create-rent'),
                        controller: rent,
                        label: 'Rent reliability',
                      ),
                      const SizedBox(height: Spacing.md),
                      _percentField(
                        key: const ValueKey('create-income'),
                        controller: income,
                        label: 'Verified income',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Credit history'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    children: [
                      _countField(
                        key: const ValueKey('create-loans'),
                        controller: loans,
                        label: 'Previous loans repaid',
                      ),
                      const SizedBox(height: Spacing.md),
                      _countField(
                        key: const ValueKey('create-missed'),
                        controller: missed,
                        label: 'Missed payments (12m)',
                      ),
                      const SizedBox(height: Spacing.md),
                      _percentField(
                        key: const ValueKey('create-obligations'),
                        controller: obligations,
                        label: 'Existing obligations',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: saving ? null : _create,
                child: saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.onInk,
                        ),
                      )
                    : const Text('Create profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _percentField({
    required Key key,
    required TextEditingController controller,
    required String label,
  }) =>
      _field(
        key: key,
        controller: controller,
        label: label,
        suffix: '%',
        hint: '0 to 100',
        keyboard: const TextInputType.numberWithOptions(decimal: true),
        formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        validator: _percent,
      );

  Widget _countField({
    required Key key,
    required TextEditingController controller,
    required String label,
  }) =>
      _field(
        key: key,
        controller: controller,
        label: label,
        hint: 'Number',
        keyboard: TextInputType.number,
        formatter: FilteringTextInputFormatter.digitsOnly,
        validator: _count,
      );

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboard,
    required TextInputFormatter formatter,
    required String? Function(String?) validator,
    String? suffix,
  }) =>
      TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: [formatter],
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator,
      );

  static String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  static String? _percent(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0 || parsed > 100) return 'Enter 0 to 100';
    return null;
  }

  static String? _count(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final parsed = int.tryParse(value!.trim());
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 0 || parsed > 99) return 'Enter 0 to 99';
    return null;
  }

  Future<void> _create() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);

    final evidence = <String, double?>{
      'utility_payment_consistency_pct': double.parse(utility.text.trim()),
      'rent_payment_reliability_pct': double.parse(rent.text.trim()),
      'verified_income_regularity_pct': double.parse(income.text.trim()),
      'previous_loan_repayment_history': double.parse(loans.text.trim()),
      'missed_payments_count_12m': double.parse(missed.text.trim()),
      'existing_financial_obligations_ratio':
          double.parse(obligations.text.trim()) / 100,
    };

    try {
      final model = await DemoRepository.loadModel();
      final assessment = model.assess(evidence);
      final hasScore = assessment.hasScore;
      final fullName = name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final applicant = Applicant(
        id: widget.state.nextApplicantId,
        name: fullName,
        initials: _initials(fullName),
        avatarAsset: 'assets/images/trustscore_icon.jpg',
        role: hasScore ? 'Evidence available' : 'Evidence still developing',
        summary: hasScore
            ? 'A model assessment is available from the submitted evidence.'
            : 'There is not enough evidence for a fair model assessment.',
        evidenceLabel:
            hasScore ? 'Sufficient evidence' : 'Insufficient evidence',
        evidenceValue: assessment.presentFeatures / _featureCount,
        pathway: hasScore
            ? AssessmentPathway.trustScore
            : AssessmentPathway.alternative,
        records: const [],
        positiveFactors: DemoRepository.positiveFactors(evidence),
        negativeFactors: DemoRepository.negativeFactors(evidence),
        evidence: evidence,
        assessment: assessment,
      );
      if (!mounted) return;

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      widget.state.addApplicant(applicant);
      widget.state.setTab(1);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            hasScore
                ? '$fullName created · TrustScore ${assessment.score}'
                : '$fullName created · more evidence needed',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not assess this profile')),
      );
    }
  }

  static String _initials(String fullName) {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
