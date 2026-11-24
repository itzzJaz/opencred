import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../demo_repository.dart';
import '../models.dart';
import '../widgets.dart';

/// Creates or edits a profile and asks Ollama to score its submitted evidence.
class CreateApplicantScreen extends StatefulWidget {
  const CreateApplicantScreen({required this.state, this.applicant, super.key});
  final DemoState state;
  final Applicant? applicant;

  @override
  State<CreateApplicantScreen> createState() => _CreateApplicantScreenState();
}

class _CreateApplicantScreenState extends State<CreateApplicantScreen> {
  static const _featureCount = 6;

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final utility = TextEditingController();
  final rent = TextEditingController();
  final income = TextEditingController();
  final loans = TextEditingController();
  final missed = TextEditingController();
  final obligations = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final applicant = widget.applicant;
    if (applicant == null) return;
    name.text = applicant.name;
    description.text = applicant.description ?? '';
    final evidence = applicant.evidence ?? const <String, double?>{};
    utility.text = _fieldValue(evidence['utility_payment_consistency_pct']);
    rent.text = _fieldValue(evidence['rent_payment_reliability_pct']);
    income.text = _fieldValue(evidence['verified_income_regularity_pct']);
    loans.text = _fieldValue(evidence['previous_loan_repayment_history']);
    missed.text = _fieldValue(evidence['missed_payments_count_12m']);
    final obligationsValue = evidence['existing_financial_obligations_ratio'];
    obligations.text = obligationsValue == null
        ? ''
        : (obligationsValue * 100).toStringAsFixed(0);
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
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
                widget.applicant == null ? 'Create profile' : 'Edit profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Add financial details, a description, or both.',
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
              const SizedBox(height: Spacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: TextFormField(
                    key: const ValueKey('applicant-description'),
                    controller: description,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'About this person (optional)',
                      hintText: 'Describe relevant payment or income history '
                          'in your own words.',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      alignLabelWithHint: true,
                    ),
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
                    : Text(widget.applicant == null
                        ? 'Create profile'
                        : 'Save changes'),
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
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0 || parsed > 100) return 'Enter 0 to 100';
    return null;
  }

  static String? _count(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 0 || parsed > 99) return 'Enter 0 to 99';
    return null;
  }

  Future<void> _create() async {
    if (!formKey.currentState!.validate()) return;
    final descriptionText = description.text.trim();
    final hasDescription = descriptionText.isNotEmpty;
    final numericValues = [utility, rent, income, loans, missed, obligations]
        .map((controller) => _parseOptional(controller.text))
        .toList();
    if (!hasDescription && numericValues.every((value) => value == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add a description or at least one number')),
      );
      return;
    }
    setState(() => saving = true);

    final evidence = <String, double?>{
      'utility_payment_consistency_pct': _parseOptional(utility.text),
      'rent_payment_reliability_pct': _parseOptional(rent.text),
      'verified_income_regularity_pct': _parseOptional(income.text),
      'previous_loan_repayment_history': _parseOptional(loans.text),
      'missed_payments_count_12m': _parseOptional(missed.text),
      'existing_financial_obligations_ratio':
          _parseOptional(obligations.text) == null
              ? null
              : _parseOptional(obligations.text)! / 100,
    };

    try {
      final assessment = await DemoRepository.assess(
        evidence,
        widget.state.ollamaConfig,
        descriptionText,
      );
      final hasScore = assessment.hasScore;
      final fullName = name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final existing = widget.applicant;
      final applicant = Applicant(
        id: existing?.id ?? widget.state.nextApplicantId,
        name: fullName,
        initials: _initials(fullName),
        avatarAsset:
            existing?.avatarAsset ?? 'assets/images/trustscore_icon.jpg',
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
        positiveFactors: assessment.positiveFactors.isNotEmpty
            ? assessment.positiveFactors
            : DemoRepository.positiveFactors(evidence),
        negativeFactors: assessment.negativeFactors.isNotEmpty
            ? assessment.negativeFactors
            : DemoRepository.negativeFactors(evidence),
        evidence: evidence,
        assessment: assessment,
        description: hasDescription ? descriptionText : null,
      );
      if (!mounted) return;

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      if (existing == null) {
        widget.state.addApplicant(applicant);
      } else {
        widget.state.updateApplicant(applicant);
      }
      widget.state.setTab(1);
      navigator.pop();
      final action = existing == null ? 'created' : 'updated';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            hasScore
                ? '$fullName $action · TrustScore ${assessment.score} · Ollama'
                : '$fullName $action · more evidence needed',
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

  static String _fieldValue(double? value) =>
      value == null ? '' : value.toStringAsFixed(0);

  static double? _parseOptional(String value) =>
      value.trim().isEmpty ? null : double.parse(value.trim());
}
