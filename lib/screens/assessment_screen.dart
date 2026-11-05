import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({required this.state, super.key});
  final DemoState state;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), children: [
    Text('AI assessment', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), Text('A transparent demonstration of the two pathways.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 22),
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [ApplicantAvatar(applicant: state.selected, size: 44), const SizedBox(width: 12), Expanded(child: Text(state.selected.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17))), const StatusPill('DEMO')]),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Evidence sufficiency', style: TextStyle(fontWeight: FontWeight.w600)),
        Text('${(state.selected.evidenceValue * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 10),
      ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: state.selected.evidenceValue, minHeight: 9, color: state.selected.hasScore ? OpenCredTheme.green : OpenCredTheme.amber, backgroundColor: Colors.grey[200])),
      const SizedBox(height: 20),
      ...state.selected.records.take(4).map((record) => _EvidenceRow(record: record)),
    ]))),
    const SizedBox(height: 18),
    ...(state.selected.hasScore
        ? [_TrustScoreCard(applicant: state.selected)]
        : [_AlternativeCard(applicant: state.selected)]),
    const SizedBox(height: 18),
    const Disclosure(title: 'AI integration pending', body: 'The model service is intentionally mocked for this demonstration. No score is generated from a live AI model, and missing evidence never becomes a low score.', icon: Icons.auto_awesome_outlined),
  ]);
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.record});
  final FinancialRecord record;
  @override
  Widget build(BuildContext context) {
    final complete = record.rent != null && record.utilities != null && record.income != null;
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      Icon(complete ? Icons.check_circle : Icons.remove_circle_outline, size: 18, color: complete ? OpenCredTheme.green : OpenCredTheme.amber),
      const SizedBox(width: 10), Expanded(child: Text(record.month, style: const TextStyle(fontWeight: FontWeight.w600))),
      Text(complete ? 'Verified records' : 'Partial records', style: TextStyle(fontSize: 12, color: complete ? OpenCredTheme.green : OpenCredTheme.amber)),
    ]));
  }
}

class _TrustScoreCard extends StatelessWidget {
  const _TrustScoreCard({required this.applicant});
  final Applicant applicant;
  @override
  Widget build(BuildContext context) {
    final score = applicant.id == 'ravi' ? 842 : 516;
    return Card(child: Padding(padding: const EdgeInsets.fromLTRB(18, 22, 18, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Illustrative TrustScore', style: TextStyle(fontWeight: FontWeight.w700)),
        StatusPill('SUPPLEMENTARY', color: _scoreColor(score)),
      ]),
      const SizedBox(height: 12),
      _TrustScoreGauge(score: score),
      const SizedBox(height: 6),
      const Text('demonstration only · supplementary information', style: TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 18),
      Align(alignment: Alignment.centerLeft, child: Text('What influenced this range', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
      const SizedBox(height: 4),
      for (final factor in applicant.positiveFactors) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.add_circle, color: OpenCredTheme.green, size: 19), title: Text(factor)),
      for (final factor in applicant.negativeFactors) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.remove_circle, color: OpenCredTheme.red, size: 19), title: Text(factor)),
    ])));
  }
}

Color _scoreColor(int score) {
  if (score < 400) return OpenCredTheme.red;
  if (score < 700) return OpenCredTheme.amber;
  return OpenCredTheme.green;
}

class _TrustScoreGauge extends StatefulWidget {
  const _TrustScoreGauge({required this.score});
  final int score;

  @override
  State<_TrustScoreGauge> createState() => _TrustScoreGaugeState();
}

class _TrustScoreGaugeState extends State<_TrustScoreGauge> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> scoreAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    scoreAnimation = _animationFor(widget.score);
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant _TrustScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      scoreAnimation = _animationFor(widget.score);
      controller
        ..reset()
        ..forward();
    }
  }

  Animation<double> _animationFor(int score) => Tween<double>(begin: 0, end: score.toDouble()).animate(
    CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: scoreAnimation,
    builder: (context, _) => SizedBox(
      width: 270,
      height: 270,
      child: CustomPaint(
        painter: _ScoreGaugePainter(score: scoreAnimation.value, color: _scoreColor(widget.score)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                scoreAnimation.value.round().toString(),
                style: const TextStyle(fontSize: 58, height: 1, fontWeight: FontWeight.w800, letterSpacing: -2),
              ),
              const SizedBox(height: 8),
              Text('/ 1000', style: TextStyle(color: Colors.brown[400], fontSize: 17, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ScoreGaugePainter extends CustomPainter {
  const _ScoreGaugePainter({required this.score, required this.color});
  final double score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 18;
    final background = Paint()
      ..color = OpenCredTheme.sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, 0, 2 * 3.141592653589793, false, background);
    canvas.drawArc(rect, -3.141592653589793 / 2, 2 * 3.141592653589793 * (score / 1000), false, progress);
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) => oldDelegate.score != score || oldDelegate.color != color;
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.applicant});
  final Applicant applicant;
  @override
  Widget build(BuildContext context) => Card(color: const Color(0xFFFFF8E8), child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const StatusPill('ALTERNATIVE ASSESSMENT', color: OpenCredTheme.amber),
    const SizedBox(height: 14), const Text('No TrustScore is shown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
    const SizedBox(height: 8), const Text('The available records are not sufficient for a fair score. This is an evidence gap, not a negative judgement.'),
    const SizedBox(height: 16), const Text('Suggested next steps', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 8), const Text('• Add documented informal income records\n• Provide cooperative or repayment evidence\n• Request an assisted human review'),
  ])));
}
