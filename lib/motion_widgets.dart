import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'motion_engine.dart';
import 'three_d_stage.dart';

export 'motion_engine.dart';

/// List with a restrained stagger on entry and subtle scroll-linked motion.
class ScrollRevealList extends StatefulWidget {
  const ScrollRevealList({
    required this.children,
    this.padding,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  State<ScrollRevealList> createState() => _ScrollRevealListState();
}

class _ScrollRevealListState extends State<ScrollRevealList> {
  late final ScrollController _controller = ScrollController();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_controller.hasClients) return;
    final extent = _controller.position.maxScrollExtent;
    _scrollProgress.value = extent <= 0
        ? 0
        : (_controller.position.pixels / extent).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final list = ListView(
      controller: _controller,
      padding: widget.padding,
      children: reduceMotion
          ? widget.children
          : [
              for (var i = 0; i < widget.children.length; i++)
                ScrollMotionItem(
                  key: ValueKey('scroll-reveal-$i'),
                  style: KineticEntranceStyle.slideUp,
                  delayMs: math.min(i * 55, 275),
                  parallaxFactor: 0.006,
                  child: widget.children[i],
                ),
            ],
    );
    final palette = Palette.of(context);
    return ScrollMotionScope(
      controller: _controller,
      child: Stack(
        children: [
          list,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: palette.hairline),
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          heightFactor: 1,
                          child: ColoredBox(color: palette.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KINETIC LAUNCH PRELOADER
// Snaps open via skewed parallelogram cutout panels (ClipPath) once per session.
// ─────────────────────────────────────────────────────────────────────────────

class EditorialPreloader extends StatefulWidget {
  const EditorialPreloader({required this.child, super.key});
  final Widget child;

  @override
  State<EditorialPreloader> createState() => _EditorialPreloaderState();
}

class _EditorialPreloaderState extends State<EditorialPreloader>
    with SingleTickerProviderStateMixin {
  static bool _sessionPlayed = false;

  late final AnimationController _ctrl;
  late final Animation<double> _slideAnim;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest || _sessionPlayed) {
      _finished = true;
      _ctrl = AnimationController(vsync: this, duration: Duration.zero);
      _slideAnim = const AlwaysStoppedAnimation(1.0);
      return;
    }

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _slideAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    // Auto-advance once mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        setState(() {
          _finished = true;
          _sessionPlayed = true;
        });
        return;
      }
      _ctrl.forward().then((_) {
        if (!mounted) return;
        setState(() {
          _finished = true;
          _sessionPlayed = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, _) {
        final t = _slideAnim.value;
        if (t >= 1.0) return widget.child;
        final exit = Curves.easeInOutCubic.transform(
          ((t - 0.86) / 0.14).clamp(0.0, 1.0),
        );
        final logo = const Interval(0.08, 0.72, curve: Curves.easeOutCubic)
            .transform(_ctrl.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            const ColoredBox(color: Color(0xFF0A0A0B)),
            RepaintBoundary(
              child: Opacity(
                opacity: 1 - exit,
                child: const ThreeDStage(
                  key: ValueKey('3d-startup-black-hole'),
                  style: ThreeDStageStyle.blackHole,
                  identity: 'TrustScore event horizon',
                  accent: Color(0xFFE10600),
                  surface: Color(0xFF05050A),
                ),
              ),
            ),
            IgnorePointer(
              child: SafeArea(
                child: Center(
                  child: Opacity(
                    opacity: (logo * 1.6).clamp(0.0, 1.0) * (1 - exit),
                    child: Transform.scale(
                      scale: 0.72 + 0.28 * logo,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(280, 150),
                            painter: _TSCalligraphyPainter(progress: logo),
                          ),
                          const SizedBox(height: Spacing.md),
                          Container(
                            width: 52 + 120 * logo,
                            height: 2,
                            color: const Color(0xFFF4F3EF),
                          ),
                          const SizedBox(height: Spacing.sm),
                          const Text(
                            'TRUSTSCORE',
                            style: TextStyle(
                              color: Color(0xFFF4F3EF),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: SafeArea(
                  top: false,
                  child: Opacity(
                    opacity: 1 - exit,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.sm,
                        Spacing.lg,
                        Spacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'TRUSTSCORE  /  LOADING THE GRID',
                                  style: TextStyle(
                                    fontFamily: 'BarlowCondensed',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: .7,
                                    color: Color(0xFFF4F3EF),
                                  ),
                                ),
                              ),
                              Text(
                                '${(_ctrl.value * 100).round()}%',
                                style: const TextStyle(
                                  fontFamily: 'BarlowCondensed',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Color(0xFFF4F3EF),
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.xs),
                          SizedBox(
                            height: 3,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                const ColoredBox(color: Color(0x66E10600)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _ctrl.value.clamp(0.0, 1.0),
                                    heightFactor: 1,
                                    child: const ColoredBox(
                                        color: Color(0xFFF4F3EF)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TSCalligraphyPainter extends CustomPainter {
  const _TSCalligraphyPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paths = <Path>[
      Path()
        ..moveTo(14, 30)
        ..cubicTo(36, 4, 84, 20, 128, 10)
        ..cubicTo(104, 20, 79, 21, 64, 24)
        ..cubicTo(62, 50, 67, 92, 57, 116)
        ..cubicTo(52, 130, 37, 132, 25, 126)
        ..cubicTo(45, 134, 72, 130, 91, 117),
      Path()
        ..moveTo(248, 25)
        ..cubicTo(226, 5, 182, 12, 162, 31)
        ..cubicTo(137, 55, 182, 60, 205, 78)
        ..cubicTo(231, 98, 205, 127, 176, 132)
        ..cubicTo(155, 135, 137, 122, 148, 108)
        ..cubicTo(157, 97, 172, 100, 178, 108),
    ];
    final totalLength = paths.fold<double>(
      0,
      (sum, path) =>
          sum + path.computeMetrics().fold(0, (n, m) => n + m.length),
    );
    var remaining = totalLength * progress.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = const Color(0xFFF4F3EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (final path in paths) {
      for (final metric in path.computeMetrics()) {
        if (remaining <= 0) return;
        final length = math.min(metric.length, remaining);
        canvas.drawPath(metric.extractPath(0, length), paint);
        remaining -= length;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TSCalligraphyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// SLANTED PARALLELOGRAM SHUTTER DIVIDER
// Kinetic angle cuts slicing between paper off-white and dark ink bands.
// ─────────────────────────────────────────────────────────────────────────────

class SkewShutterDivider extends StatelessWidget {
  const SkewShutterDivider({
    this.fromDark = false,
    this.height = 36.0,
    super.key,
  });

  final bool fromDark;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final topColor = fromDark ? const Color(0xFF0A0A0B) : palette.canvas;
    final bottomColor = fromDark ? palette.canvas : const Color(0xFF0A0A0B);

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SkewShutterPainter(
          topColor: topColor,
          bottomColor: bottomColor,
          accentColor: palette.accent,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SkewShutterPainter extends CustomPainter {
  const _SkewShutterPainter({
    required this.topColor,
    required this.bottomColor,
    required this.accentColor,
  });

  final Color topColor;
  final Color bottomColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Top fill
    canvas.drawRect(Offset.zero & size, Paint()..color = topColor);

    // Slanted bottom slice
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = bottomColor);

    // 1px hairline edge
    final linePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height * 0.25),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_SkewShutterPainter old) =>
      old.topColor != topColor ||
      old.bottomColor != bottomColor ||
      old.accentColor != accentColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// HORIZONTAL SCROLL-SCRUBBED GIANT BANNER (Leclerc-inspired)
// Continuous seamless infinite loop that scrubs dynamically with scroll velocity.
// ─────────────────────────────────────────────────────────────────────────────

class HorizontalScrollBanner extends StatelessWidget {
  const HorizontalScrollBanner({
    required this.text,
    required this.scrollController,
    this.scrubSpeed = 0.5,
    this.height = 96.0,
    super.key,
  });

  final String text;
  final ScrollController scrollController;
  final double scrubSpeed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SeamlessContinuousMarquee(
      text: text,
      scrollController: scrollController,
      height: height,
      scrubMultiplier: scrubSpeed,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCROLL-DRAWN VECTOR STROKE
// Precision SVG/CustomPainter that paints a crimson line dynamically as you scroll.
// ─────────────────────────────────────────────────────────────────────────────

class ScrollDrawnStroke extends StatefulWidget {
  const ScrollDrawnStroke({
    required this.scrollController,
    this.triggerOffset = 180.0,
    this.drawRange = 260.0,
    this.height = 48.0,
    super.key,
  });

  final ScrollController scrollController;
  final double triggerOffset;
  final double drawRange;
  final double height;

  @override
  State<ScrollDrawnStroke> createState() => _ScrollDrawnStrokeState();
}

class _ScrollDrawnStrokeState extends State<ScrollDrawnStroke> {
  final _progress = ValueNotifier<double>(0);

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final raw = (widget.scrollController.offset - widget.triggerOffset) /
        widget.drawRange;
    _progress.value = raw.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SizedBox(
      height: widget.height,
      child: ValueListenableBuilder<double>(
        valueListenable: _progress,
        builder: (context, t, _) => CustomPaint(
          painter: _StrokePainter(
            progress: t,
            activeColor: palette.accent,
            trackColor: palette.hairline,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h / 2;

    final path = Path()
      ..moveTo(0, mid)
      ..lineTo(w * 0.35, mid)
      ..lineTo(w * 0.45, h * 0.15)
      ..lineTo(w * 0.55, h * 0.85)
      ..lineTo(w * 0.65, mid)
      ..lineTo(w, mid);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, trackPaint);

    // Dynamic stroke
    if (progress > 0) {
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final drawn = metric.extractPath(0, metric.length * progress);
        final activePaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(drawn, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.progress != progress || old.activeColor != activeColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTCHED FOLDER-TAB CARD (Charles Leclerc style)
// Flat architectural card with small notched top-left label tab and 1px hairlines.
// ─────────────────────────────────────────────────────────────────────────────

class NotchedFolderCard extends StatelessWidget {
  const NotchedFolderCard({
    required this.tabLabel,
    required this.child,
    this.trailingTag,
    this.backgroundColor,
    super.key,
  });

  final String tabLabel;
  final Widget child;
  final String? trailingTag;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final fill = backgroundColor ?? palette.surface;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(Radii.card),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: palette.hairline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top notched tab header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: palette.hairline, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    color: palette.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tabLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: palette.secondary,
                      ),
                    ),
                  ),
                  if (trailingTag != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      trailingTag!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDITORIAL DOT-LABEL (Tracked uppercase small labels)
// ─────────────────────────────────────────────────────────────────────────────

class EditorialDotLabel extends StatelessWidget {
  const EditorialDotLabel(
    this.text, {
    this.number,
    this.color,
    super.key,
  });

  final String text;
  final String? number;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final fg = color ?? palette.secondary;
    return Row(
      children: [
        if (number != null) ...[
          Text(
            number!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: palette.accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '/',
            style: TextStyle(fontSize: 10, color: palette.muted),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          width: 5,
          height: 5,
          color: palette.accent,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KINETIC PROGRESS BAR
// Smoothly animated telemetry fill with leading cursor indicator.
// ─────────────────────────────────────────────────────────────────────────────

class KineticProgressBar extends StatelessWidget {
  const KineticProgressBar({
    required this.value,
    this.height = 5,
    this.color,
    this.backgroundColor,
    super.key,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final activeColor = color ?? palette.accent;
    final bgColor = backgroundColor ?? palette.raised;
    final clamped = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: clamped),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Radii.row),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * val;
              return Stack(
                children: [
                  Container(
                    width: fillWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(Radii.row),
                    ),
                  ),
                  if (fillWidth > 2)
                    Positioned(
                      left: fillWidth - 2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MANIFESTO HEADLINE (Mixed-voice Serif Accent in Grotesque Uppercase)
// ─────────────────────────────────────────────────────────────────────────────

class ManifestoHeadline extends StatelessWidget {
  const ManifestoHeadline({
    required this.standardBefore,
    required this.serifAccent,
    required this.standardAfter,
    this.fontSize = 32.0,
    super.key,
  });

  final String standardBefore;
  final String serifAccent;
  final String standardAfter;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          height: 0.96,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: palette.ink,
        ),
        children: [
          if (standardBefore.isNotEmpty) TextSpan(text: '$standardBefore '),
          TextSpan(
            text: serifAccent,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontFamily: 'Georgia',
            ),
          ),
          if (standardAfter.isNotEmpty) TextSpan(text: ' $standardAfter'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOCK WIPE TEXT (Kinetic solid block unmask)
// ─────────────────────────────────────────────────────────────────────────────

class BlockWipeText extends StatefulWidget {
  const BlockWipeText(
    this.text, {
    this.style,
    this.delayMs = 0,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final int delayMs;

  @override
  State<BlockWipeText> createState() => _BlockWipeTextState();
}

class _BlockWipeTextState extends State<BlockWipeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Stack(
      children: [
        Text(widget.text, style: widget.style),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: (1.0 - _anim.value).clamp(0.0, 1.0),
              child: ColoredBox(color: palette.accent),
            ),
          ),
        ),
      ],
    );
  }
}
