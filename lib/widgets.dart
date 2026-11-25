import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models.dart';

/// Page title and one line of context. Every screen starts with this so the
/// first baseline sits at the same height everywhere.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 3,
                  color: palette.accent,
                ),
                const SizedBox(height: Spacing.sm),
                Text(title.toUpperCase(),
                    style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: palette.secondary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Spacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Section label inside a scrolling canvas.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Status as a quiet dot and a short label. This is the app's signature
/// detail: state is never a glowing capsule with uppercase text.
class StatusLabel extends StatelessWidget {
  const StatusLabel(
    this.label, {
    this.color,
    this.showDot = true,
    super.key,
  });

  final String label;
  final Color? color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final resolved = color ?? palette.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: resolved, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'BarlowCondensed',
              fontSize: 12,
              height: 1.33,
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              color: resolved,
            ),
          ),
        ),
      ],
    );
  }
}

/// Muted meta line, used for counts, ids and dates.
class MetaText extends StatelessWidget {
  const MetaText(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'BarlowCondensed',
        fontSize: 12.5,
        height: 1.33,
        fontWeight: FontWeight.w500,
        letterSpacing: .35,
        color: color ?? palette.muted,
      ),
    );
  }
}

class ApplicantAvatar extends StatelessWidget {
  const ApplicantAvatar({required this.applicant, this.size = 52, super.key});

  final Applicant applicant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.raised,
        border: Border.all(color: palette.hairline),
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size.square(size),
          painter: _ApplicantPortraitPainter(
            identity: '${applicant.id}:${applicant.name}',
            isDark: palette.isDark,
          ),
        ),
      ),
    );
  }
}

class _ApplicantPortraitPainter extends CustomPainter {
  _ApplicantPortraitPainter({required this.identity, required this.isDark})
      : seed = _stableSeed(identity);

  final String identity;
  final bool isDark;
  final int seed;

  static int _stableSeed(String input) {
    var value = 0x811c9dc5;
    for (final byte in input.codeUnits) {
      value = ((value ^ byte) * 0x01000193) & 0x7fffffff;
    }
    return value;
  }

  double _unit(int offset) => ((seed >> (offset % 24)) & 0xff) / 255;

  Color _hue(double hue, double saturation, double lightness) =>
      HSLColor.fromAHSL(1, hue % 360, saturation, lightness).toColor();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final hue = (_unit(1) * 360 + 8).roundToDouble();
    final skinTones = [
      const Color(0xFFF1C8A5),
      const Color(0xFFDDA47E),
      const Color(0xFFBD805D),
      const Color(0xFF8E5C46),
      const Color(0xFF694536),
      const Color(0xFFAA7355),
    ];
    final skin = skinTones[seed % skinTones.length];
    final hair = [
      const Color(0xFF191916),
      const Color(0xFF33251F),
      const Color(0xFF4B3428),
      const Color(0xFF171D24),
      const Color(0xFF51463C),
    ][(seed ~/ 7) % 5];
    final clothes = _hue(
      (seed % 3 == 0) ? 350 : hue,
      .48 + _unit(7) * .25,
      isDark ? .54 : .42,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _hue(hue, .42, isDark ? .25 : .83),
            _hue(hue + 45, .56, isDark ? .13 : .68),
          ],
        ).createShader(rect),
    );

    final haloPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? .075 : .20);
    canvas.drawCircle(Offset(w * .5, h * .36), w * .36, haloPaint);
    canvas.drawCircle(
      Offset(w * .5, h * .36),
      w * .31,
      Paint()
        ..color = Colors.white.withValues(alpha: .08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .012,
    );

    // Shoulders and torso
    final body = Path()
      ..moveTo(w * .06, h)
      ..lineTo(w * .09, h * .84)
      ..quadraticBezierTo(w * .14, h * .72, w * .36, h * .68)
      ..lineTo(w * .64, h * .68)
      ..quadraticBezierTo(w * .87, h * .72, w * .92, h * .84)
      ..lineTo(w * .95, h)
      ..close();
    canvas.drawPath(body, Paint()..color = clothes);
    canvas.drawPath(
      Path()
        ..moveTo(w * .39, h * .71)
        ..lineTo(w * .5, h * .88)
        ..lineTo(w * .62, h * .71),
      Paint()
        ..color = Colors.white.withValues(alpha: .5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .025
        ..strokeCap = StrokeCap.round,
    );

    // Neck and ears
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * .42, h * .57, w * .58, h * .78),
        Radius.circular(w * .06),
      ),
      Paint()..color = skin,
    );
    canvas.drawOval(
      Rect.fromLTRB(w * .265, h * .37, w * .36, h * .53),
      Paint()..color = skin,
    );
    canvas.drawOval(
      Rect.fromLTRB(w * .64, h * .37, w * .735, h * .53),
      Paint()..color = skin,
    );

    // Face
    final face = Rect.fromLTRB(w * .30, h * .19, w * .70, h * .63);
    canvas.drawOval(face, Paint()..color = skin);
    canvas.drawOval(
      Rect.fromLTRB(w * .33, h * .36, w * .67, h * .63),
      Paint()..color = skin.withValues(alpha: .18),
    );

    // Hairline and a few distinct silhouette styles.
    final hairPath = Path()..moveTo(w * .285, h * .42);
    final style = seed % 4;
    if (style == 0) {
      hairPath
        ..cubicTo(w * .20, h * .04, w * .80, h * .04, w * .715, h * .42)
        ..quadraticBezierTo(w * .66, h * .28, w * .55, h * .31)
        ..quadraticBezierTo(w * .40, h * .34, w * .285, h * .42);
    } else if (style == 1) {
      hairPath
        ..cubicTo(w * .25, h * .08, w * .72, h * .08, w * .72, h * .4)
        ..lineTo(w * .67, h * .49)
        ..lineTo(w * .64, h * .33)
        ..quadraticBezierTo(w * .46, h * .25, w * .31, h * .37)
        ..lineTo(w * .30, h * .49);
    } else if (style == 2) {
      hairPath
        ..cubicTo(w * .17, h * .1, w * .79, h * .05, w * .74, h * .46)
        ..quadraticBezierTo(w * .68, h * .22, w * .48, h * .29)
        ..quadraticBezierTo(w * .36, h * .29, w * .285, h * .42);
    } else {
      hairPath
        ..cubicTo(w * .22, h * .04, w * .78, h * .08, w * .72, h * .43)
        ..lineTo(w * .68, h * .55)
        ..lineTo(w * .65, h * .36)
        ..quadraticBezierTo(w * .43, h * .24, w * .31, h * .4)
        ..lineTo(w * .30, h * .53);
    }
    hairPath.close();
    canvas.drawPath(hairPath, Paint()..color = hair);

    final eyePaint = Paint()..color = const Color(0xFF252421);
    final eyeY = h * .445;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * .414, eyeY), width: w * .038, height: w * .025),
        eyePaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * .586, eyeY), width: w * .038, height: w * .025),
        eyePaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * .50, h * .45)
        ..quadraticBezierTo(w * .475, h * .52, w * .51, h * .535),
      Paint()
        ..color = hair.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .018
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .445, h * .57)
        ..quadraticBezierTo(
            w * .50, h * (.585 + _unit(13) * .015), w * .555, h * .57),
      Paint()
        ..color = const Color(0xFF7E3D3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .018
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ApplicantPortraitPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.isDark != isDark;
}

/// Label on the left, value on the right, both on a shared baseline and a
/// shared row height. Values are tabular through the theme. The value keeps
/// its natural width up to 60% of the row, so the label never gets squeezed
/// in half; long labels wrap instead of truncating.
class MetricRow extends StatelessWidget {
  const MetricRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: palette.secondary),
                ),
              ),
              const SizedBox(width: Spacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * .6,
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The score band shared by the overview strip and the assessment card.
(String, Color) scoreBand(Palette palette, int score) {
  if (score >= 700) return ('Strong', palette.positive);
  if (score >= 400) return ('Fair', palette.secondary);
  return ('Developing', palette.warning);
}

/// One row inside an evidence list: signature dot, label, quiet state.
class EvidenceRow extends StatelessWidget {
  const EvidenceRow({
    required this.label,
    required this.state,
    required this.complete,
    super.key,
  });

  final String label;
  final String state;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: complete ? palette.positive : palette.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          MetaText(
            state,
            color: complete ? palette.secondary : palette.warning,
          ),
        ],
      ),
    );
  }
}
