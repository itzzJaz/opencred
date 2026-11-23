import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../demo_repository.dart';
import '../models.dart';
import '../ollama_client.dart';
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
                  meta:
                      'Synthetic profiles · bundled model with optional Ollama',
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
        const SectionHeader(title: 'TrustScore model'),
        _OllamaCard(state: state),
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

/// Runtime configuration for the Ollama server on the operator's laptop.
/// Values default to `OLLAMA_BASE_URL` / `OLLAMA_MODEL` build defines and can
/// be changed here without rebuilding.
class _OllamaCard extends StatefulWidget {
  const _OllamaCard({required this.state});
  final DemoState state;

  @override
  State<_OllamaCard> createState() => _OllamaCardState();
}

class _OllamaCardState extends State<_OllamaCard> {
  late final TextEditingController url;
  late final TextEditingController model;
  late bool enabled;
  bool testing = false;
  String? status;
  bool statusIsError = false;

  @override
  void initState() {
    super.initState();
    final config = widget.state.ollamaConfig;
    url = TextEditingController(text: config.baseUrl);
    model = TextEditingController(text: config.model);
    enabled = config.enabled;
  }

  @override
  void dispose() {
    url.dispose();
    model.dispose();
    super.dispose();
  }

  OllamaConfig get _config => OllamaConfig(
        baseUrl: url.text.trim(),
        model: model.text.trim(),
        enabled: enabled,
      );

  void _save() {
    widget.state.setOllamaConfig(_config);
    setState(() {
      status = 'Saved. Open Assessment to score with Ollama.';
      statusIsError = false;
    });
  }

  Future<void> _test() async {
    setState(() {
      testing = true;
      status = null;
    });
    try {
      final models = await DemoRepository.testOllama(_config);
      if (!mounted) return;
      setState(() {
        final installed = models.take(4).join(', ');
        status = models.isEmpty
            ? 'Connected to Ollama, but no models are installed.'
            : 'Connected · $installed';
        statusIsError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        status = 'Could not reach Ollama. Check the URL and that the server '
            'is running with OLLAMA_HOST=0.0.0.0.';
        statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score with Ollama on my laptop',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'The bundled model is used when the laptop is off.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: palette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Switch.adaptive(
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              key: const ValueKey('ollama-url'),
              controller: url,
              enabled: enabled,
              autocorrect: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ollama base URL',
                hintText: 'http://192.168.1.20:11434',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            TextField(
              key: const ValueKey('ollama-model'),
              controller: model,
              enabled: enabled,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'llama3.2',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Start Ollama so other devices can reach it with '
              'OLLAMA_HOST=0.0.0.0 ollama serve. Android emulator: '
              'http://10.0.2.2:11434. Phone: your laptop’s LAN IP.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: palette.muted,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: enabled && !testing ? _test : null,
                    child: testing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.muted,
                            ),
                          )
                        : const Text('Test connection'),
                  ),
                ),
              ],
            ),
            if (status != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                status!,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: statusIsError ? palette.negative : palette.positive,
                ),
              ),
            ],
          ],
        ),
      ),
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
