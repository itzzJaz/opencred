import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencred/ollama_client.dart';
import 'package:opencred/trustscore_engine.dart';
import 'package:opencred/trustscore_model.dart';

const _config = OllamaConfig(
  baseUrl: 'http://192.168.1.20:11434',
  model: 'llama3.2',
);

Map<String, double?> _evidence({double? missed = 0}) => {
      'utility_payment_consistency_pct': 92,
      'rent_payment_reliability_pct': 88,
      'verified_income_regularity_pct': 80,
      'previous_loan_repayment_history': 3,
      'missed_payments_count_12m': missed,
      'existing_financial_obligations_ratio': .24,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('posts evidence and parses a scored Ollama response', () async {
    late http.Request captured;
    final client = OllamaClient(
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'message': {
              'content': jsonEncode({
                'status': 'scored',
                'score': 812,
                'probability': .812,
                'positive_factors': ['Regular verified income'],
                'negative_factors': ['Higher obligations ratio'],
                'limitation': 'Supplementary prototype output.',
              }),
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.assess(
      config: _config,
      evidence: _evidence(),
      requiredFeatures: 4,
    );

    expect(captured.url.toString(), 'http://192.168.1.20:11434/api/chat');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['model'], 'llama3.2');
    expect(body['stream'], isFalse);
    expect(body['format'], 'json');
    // Only features leave the device, never a name or identifier.
    final messages = body['messages'] as List;
    expect((messages.last as Map)['content'], contains('92.0'));
    expect(captured.body, isNot(contains('Ravi')));

    expect(result.status, 'scored');
    expect(result.score, 812);
    expect(result.probability, closeTo(.812, .0001));
    expect(result.isOllama, isTrue);
    expect(result.modelVersion, 'ollama/llama3.2');
    expect(result.positiveFactors, ['Regular verified income']);
  });

  test('tolerates a fenced JSON reply', () async {
    final client = OllamaClient(
      client: MockClient((_) async => http.Response(
            jsonEncode({
              'message': {
                'content': '```json\n{"status":"scored","score":640}\n```',
              },
            }),
            200,
          )),
    );

    final result = await client.assess(
      config: _config,
      evidence: _evidence(),
      requiredFeatures: 4,
    );
    expect(result.score, 640);
  });

  test('falls back to the bundled model when Ollama is unreachable', () async {
    final local = await TrustScoreModel.load();
    final result = await TrustScoreEngine.assess(
      local: local,
      evidence: _evidence(),
      config: _config,
      client: OllamaClient(
        client: MockClient((_) async => http.Response('down', 503)),
      ),
    );

    expect(result.status, 'scored');
    expect(result.isOllama, isFalse);
    expect(result.modelVersion, isNot(startsWith('ollama/')));
  });

  test('sparse evidence never reaches the laptop model', () async {
    final local = await TrustScoreModel.load();
    var calls = 0;
    final result = await TrustScoreEngine.assess(
      local: local,
      evidence: {
        'utility_payment_consistency_pct': 92,
        'rent_payment_reliability_pct': null,
        'verified_income_regularity_pct': null,
        'previous_loan_repayment_history': null,
        'missed_payments_count_12m': null,
        'existing_financial_obligations_ratio': null,
      },
      config: _config,
      client: OllamaClient(
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
      ),
    );

    expect(calls, 0);
    expect(result.status, 'insufficient_evidence');
    expect(result.score, isNull);
  });
}
