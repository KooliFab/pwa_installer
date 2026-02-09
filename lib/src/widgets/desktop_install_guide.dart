import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/theme.dart';
import '../theme/labels.dart';

/// A screen that guides desktop users to install the PWA on their mobile device.
///
/// Displays a QR code with the current URL that users can scan with their
/// mobile device, along with platform-specific installation instructions.
class DesktopInstallGuide extends StatelessWidget {
  /// Logo widget to display at the top of the screen.
  final Widget? logo;

  /// App name to display in the title.
  final String? appName;

  /// Theme for customizing colors and styling.
  final PwaInstallerTheme theme;

  /// Labels for customizing text (useful for i18n).
  final PwaInstallerLabels labels;

  /// Callback when user dismisses the screen.
  final VoidCallback? onDismiss;

  /// Custom URL to encode in the QR code.
  final String? customUrl;

  const DesktopInstallGuide({
    super.key,
    this.logo,
    this.appName,
    this.theme = const PwaInstallerTheme(),
    this.labels = const PwaInstallerLabels(),
    this.onDismiss,
    this.customUrl,
  });

  String get _currentUrl {
    if (customUrl != null) return customUrl!;
    if (!kIsWeb) return 'https://example.com';
    return web.window.location.href;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme.backgroundGradient != null ? theme : PwaInstallerTheme.defaultTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: effectiveTheme.backgroundGradient,
          color: effectiveTheme.backgroundGradient == null ? effectiveTheme.backgroundColor : null,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: effectiveTheme.contentPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    if (logo != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius + 8),
                        ),
                        child: logo,
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      appName != null ? labels.desktopTitle.replaceAll('this app', appName!) : labels.desktopTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: effectiveTheme.textColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      labels.desktopDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: effectiveTheme.textColor.withValues(alpha: 0.8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildQrCode(context, effectiveTheme),
                    const SizedBox(height: 32),
                    _buildInstallationInstructions(context, effectiveTheme),
                    if (onDismiss != null) ...[
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: onDismiss,
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                        child: Text(labels.desktopDismissButton, style: TextStyle(color: effectiveTheme.textColor.withValues(alpha: 0.7), fontSize: 16)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCode(BuildContext context, PwaInstallerTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(theme.borderRadius + 8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: QrImageView(
        data: _currentUrl,
        version: QrVersions.auto,
        size: 200,
        backgroundColor: Colors.white,
        errorStateBuilder: (context, error) => Center(child: Text(labels.desktopQrError, textAlign: TextAlign.center, style: TextStyle(color: theme.secondaryTextColor))),
      ),
    );
  }

  Widget _buildInstallationInstructions(BuildContext context, PwaInstallerTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(labels.desktopHowToInstall, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: theme.textColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 16),
        _InstructionStep(icon: Icons.apple, title: labels.desktopIosTitle, steps: [labels.desktopIosStep1, labels.desktopIosStep2, labels.desktopIosStep3], theme: theme),
        const SizedBox(height: 24),
        _InstructionStep(icon: Icons.android, title: labels.desktopAndroidTitle, steps: [labels.desktopAndroidStep1, labels.desktopAndroidStep2], theme: theme),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> steps;
  final PwaInstallerTheme theme;

  const _InstructionStep({required this.icon, required this.title, required this.steps, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: theme.textColor),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: theme.textColor, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.textColor.withValues(alpha: 0.9))),
                Expanded(child: Text(step, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.textColor.withValues(alpha: 0.9)))),
              ],
            ),
          );
        }),
      ],
    );
  }
}
