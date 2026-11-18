import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models.dart';
import '../widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.state, super.key});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Layout.pageGutter,
        Spacing.lg,
        Layout.pageGutter,
        Layout.pageBottomInset,
      ),
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'Preferences',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              children: [
                const _SettingRow(
                  title: 'Demo build',
                  meta: 'Synthetic profiles, no live services',
                ),
                const Divider(),
                _SettingRow(
                  title: 'Reset demo',
                  meta: 'Clear progress and return to the first profile',
                  onTap: state.reset,
                  trailing:
                      Icon(Icons.restart_alt, size: 18, color: palette.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        const SectionHeader(title: 'Appearance'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'System, light or dark',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: palette.secondary,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                _ThemeSwitch(state: state),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        const SectionHeader(title: 'About'),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: Column(
              children: [
                MetricRow(label: 'Version', value: '1.0.0 (4)'),
                Divider(),
                MetricRow(label: 'Data', value: 'Synthetic profiles'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Three-segment appearance control. It uses the same raised capsule and ink
/// fill as the selected filter pill, so the app has one selected-state look.
class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({required this.state});
  final DemoState state;

  static const _options = [
    (ThemeMode.system, 'System'),
    (ThemeMode.light, 'Light'),
    (ThemeMode.dark, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.xxs),
      decoration: BoxDecoration(
        color: palette.raised,
        borderRadius: BorderRadius.circular(Radii.capsule),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        children: [
          for (final option in _options)
            Expanded(
              child: Semantics(
                button: true,
                selected: state.themeMode == option.$1,
                label: '${option.$2} theme',
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.capsule),
                  onTap: () => state.setThemeMode(option.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    height: 40,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: state.themeMode == option.$1
                          ? palette.ink
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.capsule),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        option.$2,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: state.themeMode == option.$1
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: state.themeMode == option.$1
                              ? palette.onInk
                              : palette.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.meta,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: palette.secondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Spacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
