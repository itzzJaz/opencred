import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A single translucent, blur-backed surface.
///
/// Liquid Glass belongs to the navigation and control layer only: floating
/// bars, controls, sheets and the group that holds filter pills. Never wrap a
/// list row, an evidence row or a data card in this widget — the content
/// canvas stays opaque and high contrast.
///
/// One instance per glass *group*. Do not nest one inside another: the second
/// blur samples nothing and costs an extra offscreen texture.
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(Radii.card)),
    this.capsule = false,
    this.blurSigma = 18,
    this.tint,
    this.rim,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  /// Stadium geometry for pills, bars and floating controls.
  final bool capsule;
  final double blurSigma;

  /// Overrides the adaptive white / ink tint when a surface needs more or less
  /// contrast against what sits behind it.
  final Color? tint;
  final Color? rim;

  /// A floating surface keeps a small neutral shadow. Bars docked to a sheet
  /// edge can turn it off.
  final bool elevated;

  static const Color _lightTint = Color(0xB8F6F4ED); // ivory at 72%
  static const Color _darkTint = Color(0x9A0C1B18); // deep emerald at 60%

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final isDark = palette.isDark;

    // When the platform asks for high contrast, the surface turns into a
    // solid tone of the current theme instead of a blur.
    final solidSurface = MediaQuery.maybeHighContrastOf(context) ?? false;

    final baseTint = tint ?? (isDark ? _darkTint : _lightTint);
    final fill =
        solidSurface ? Color.alphaBlend(baseTint, palette.surface) : baseTint;
    final radius = capsule
        ? const BorderRadius.all(Radius.circular(Radii.capsule))
        : borderRadius;
    final rimColor =
        rim ?? Colors.white.withValues(alpha: isDark ? 0.18 : 0.22);
    final sheen = Colors.white.withValues(alpha: isDark ? 0.10 : 0.45);

    final glass = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: rimColor),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // A 1px specular rim along the top edge, the way light catches
              // real glass. It sits under the content, never over it.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(height: 1, color: sheen),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );

    if (!elevated) {
      return glass;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: glass,
    );
  }
}

/// Shows a modal sheet on a glass surface.
///
/// The handle, the top corners and the sheet's own padding are handled here so
/// every sheet in the app reads the same.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double heightFactor = 0.86,
}) {
  final palette = Palette.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x66081714),
    elevation: 0,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      return Padding(
        padding: EdgeInsets.only(
          top: media.size.height * (1 - heightFactor),
        ),
        child: LiquidGlassSurface(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          padding: const EdgeInsets.only(top: Spacing.xs),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(color: palette.muted),
                Flexible(child: builder(sheetContext)),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xs),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

/// One destination in the floating bottom nav.
class GlassNavDestination {
  const GlassNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The floating bottom pill. Labels are always visible, so the bar stays
/// readable for screen readers and for anyone who does not recognise an icon.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<GlassNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      capsule: true,
      padding: const EdgeInsets.all(Spacing.xxs),
      child: Row(
        children: [
          for (var i = 0; i < destinations.length; i++)
            Expanded(
              child: _NavItem(
                destination: destinations[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final GlassNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final foreground = selected ? palette.onInk : palette.secondary;
    final fill = selected ? palette.ink : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            height: Layout.navItemHeight,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(destination.icon, size: 20, color: foreground),
                const SizedBox(height: Spacing.xxs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A filter pill. It is designed to sit inside a group that owns the blur and
/// the tint, so the pill itself is a solid, cheap surface.
class GlassPill extends StatelessWidget {
  const GlassPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final foreground = selected ? palette.onInk : palette.secondary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.capsule),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected ? palette.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.capsule),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.2,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
