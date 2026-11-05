import 'package:flutter/services.dart';
import 'models.dart';

class DemoRepository {
  static Future<List<Applicant>> loadApplicants() async {
    final definitions = [
      ('ravi', 'Ravi Kumar', 'RK', 'Consistent household finances',
          'assets/images/ravi_profile.png',
          'Strong evidence across rent, utilities, income and repayments.', 'High evidence', .94,
          AssessmentPathway.trustScore, ['Reliable rent payments', 'Stable verified income']),
      ('arjun', 'Arjun Patel', 'AP', 'Evidence still developing',
          'assets/images/arjun_profile.png',
          'Some records are available, but a fair score cannot be produced yet.', 'Insufficient evidence', .42,
          AssessmentPathway.alternative, ['Income records are partial', 'Alternative verification recommended']),
      ('vikram', 'Vikram Singh', 'VS', 'Irregular payment behaviour',
          'assets/images/vikram_profile.png',
          'Sufficient records show repeated late and missed payments.', 'Sufficient evidence', .86,
          AssessmentPathway.trustScore, ['Verified income is irregular', 'Late rent and utility payments']),
    ];
    final applicants = <Applicant>[];
    for (final definition in definitions) {
      final records = await _loadRecords(definition.$1);
      applicants.add(Applicant(
        id: definition.$1,
        name: definition.$2,
        initials: definition.$3,
        role: definition.$4,
        avatarAsset: definition.$5,
        summary: definition.$6,
        evidenceLabel: definition.$7,
        evidenceValue: definition.$8,
        pathway: definition.$9,
        records: records,
        positiveFactors: definition.$10,
        negativeFactors: records.any((record) => record.repayment == 'late' || record.repayment == 'missed')
            ? ['Repeated overdue payments', 'Income varies month to month']
            : ['Six months of payment history', 'Income source verified'],
      ));
    }
    return applicants;
  }

  static Future<List<FinancialRecord>> _loadRecords(String id) async {
    final fileName = switch (id) {
      'ravi' => 'ravi_kumar.csv',
      'arjun' => 'arjun_patel.csv',
      'vikram' => 'vikram_singh.csv',
      _ => throw ArgumentError('Unknown demo applicant: $id'),
    };
    final csv = await rootBundle.loadString('assets/data/$fileName');
    return csv.trim().split('\n').skip(1).map((line) {
      final values = line.split(',');
      double? number(String value) => value.isEmpty ? null : double.tryParse(value);
      return FinancialRecord(
        month: values[0],
        rent: number(values[1]),
        utilities: number(values[2]),
        income: number(values[3]),
        repayment: values[4],
      );
    }).toList();
  }
}
