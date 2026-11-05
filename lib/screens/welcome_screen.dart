import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({required this.state, super.key});
  final DemoState state;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<Offset> slide;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    fade = curved;
    slide = Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(curved);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 28), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/images/trustscore_icon.jpg', width: 42, height: 42, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        const Text('TRUSTSCORE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800)),
      ]),
      const Spacer(),
      const Text('Trust beyond\ncredit history.', style: TextStyle(fontSize: 44, height: 1.03, letterSpacing: -1.5, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      Text('A responsible, explainable view of financial behaviour for people whose story is bigger than a credit file.', style: TextStyle(fontSize: 17, color: Colors.grey[700], height: 1.4)),
      const SizedBox(height: 24),
      const Disclosure(title: 'Offline Judge Demo', body: 'Explore fictional applicants, simulated verification and a mock assessment. No real identity numbers or external services are used.'),
      const Spacer(),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: widget.state.startDemo, child: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Start demonstration')))),
      const SizedBox(height: 12), Center(child: Text('TrustScore · GEMS Innovation Challenge', style: TextStyle(color: Colors.grey, fontSize: 12))),
    ]))))),
  );
}
