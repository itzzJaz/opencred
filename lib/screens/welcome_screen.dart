import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({required this.state, super.key});
  final DemoState state;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<Offset> rise;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final curved =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    fade = curved;
    rise = Tween<Offset>(begin: const Offset(0, .012), end: Offset.zero)
        .animate(curved);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    const padding = EdgeInsets.all(Spacing.lg);
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: rise,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  // Composed as a whole when it fits; scrolls instead of
                  // clipping when the text is large.
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - padding.vertical,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: palette.hairline),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.asset(
                                'assets/images/trustscore_icon.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            'TrustScore',
                            style: TextStyle(
                              fontSize: 17,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 2,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            'Trust beyond\ncredit history',
                            style: TextStyle(
                              fontSize: 40,
                              height: 1.08,
                              letterSpacing: -0.8,
                              fontWeight: FontWeight.w500,
                              color: palette.ink,
                            ),
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            'A view of financial behaviour for people without a conventional credit history.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: palette.secondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: widget.state.startDemo,
                            child: const Text('Get started'),
                          ),
                          const SizedBox(height: Spacing.sm),
                          const Center(
                            child: MetaText(
                              'TrustScore · GEMS Innovation Challenge',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
