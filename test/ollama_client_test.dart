import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencred/ollama_client.dart';
import 'package:opencred/trustscore_engine.dart';

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

  test('retries without structured output when the server rejects it',
      () async {
    final requests = <Map<String, dynamic>>[];
    final client = OllamaClient(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requests.add(body);
        if (body.containsKey('format')) {
          return http.Response(
            '{"error":"structured output is unavailable"}',
            501,
          );
        }
        return http.Response(
          jsonEncode({
            'message': {
              'content': '{"status":"scored","score":701}',
            },
          }),
          200,
        );
      }),
    );

    final result = await client.assess(
      config: _config,
      evidence: _evidence(),
    );

    expect(requests, hasLength(6));
    expect(requests.first['format'], 'json');
    expect(requests.first['think'], isFalse);
    expect(requests.last.containsKey('format'), isFalse);
    expect(requests.last['think'], isFalse);
    expect(result.score, 701);
    expect(result.isOllama, isTrue);
  });

  test('explains a model that is not installed', () async {
    final client = OllamaClient(
      client: MockClient((_) async => http.Response(
            '{"error":"model \'llama3.2\' not found"}',
            404,
          )),
    );

    expect(
      () => client.assess(
        config: _config,
        evidence: _evidence(),
      ),
      throwsA(
        isA<OllamaException>().having(
          (error) => error.message,
          'message',
          allOf(contains('not installed'), contains('llama3.2')),
        ),
      ),
    );
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
    );
    expect(result.score, 640);
  });

  test('scores a plain-English description with no numeric values', () async {
    var calls = 0;
    final client = OllamaClient(
      client: MockClient((request) async {
        calls++;
        expect(request.body, contains('Pays rent on time'));
        return http.Response(
          jsonEncode({
            'message': {
              'content': '{"status":"scored","score":670,"probability":0.67}',
            },
          }),
          200,
        );
      }),
    );
    final result = await TrustScoreEngine.assessDetailed(
      evidence: {for (final key in _evidence().keys) key: null},
      config: _config,
      description: 'Pays rent on time and receives regular income.',
      client: client,
    );

    expect(calls, 3);
    expect(result.assessment.score, 670);
    expect(result.cache?.scores, [670, 670, 670]);
  });
}
