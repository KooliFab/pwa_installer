import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../core/platform_detection.dart';
import '../theme/theme.dart';
import '../theme/labels.dart';

/// A screen that instructs users to open the app in their system browser.
///
/// Shows when the app is running in an in-app browser (Instagram, Facebook, etc.)
/// that doesn't support PWA installation.
class InAppBrowserGuide extends StatefulWidget {
  /// Custom theme for styling.
  final PwaInstallerTheme? theme;

  /// Custom labels for localization.
  final PwaInstallerLabels? labels;

  /// Optional logo widget to display at the top.
  final Widget? logo;

  /// Whether to attempt automatic redirect on mount.
  final bool autoRedirect;

  /// Callback when the user dismisses the screen.
  final VoidCallback? onDismiss;

  const InAppBrowserGuide({
    super.key,
    this.theme,
    this.labels,
    this.logo,
    this.autoRedirect = false,
    this.onDismiss,
  });

  @override
  State<InAppBrowserGuide> createState() => _InAppBrowserGuideState();
}

class _InAppBrowserGuideState extends State<InAppBrowserGuide> {
  late final InAppBrowserDetection _detection;
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    _detection = PlatformDetection.detectInAppBrowser();

    if (widget.autoRedirect) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _attemptBrowserRedirect();
      });
    }
  }

  Future<void> _attemptBrowserRedirect() async {
    if (!kIsWeb) return;

    final currentUrl = Uri.parse(web.window.location.href);
    final isIOS = PlatformDetection.isIos();
    final isAndroid = PlatformDetection.isAndroid();

    if (isAndroid) {
      final host = web.window.location.host;
      final path = web.window.location.pathname +
          web.window.location.search +
          web.window.location.hash;

      final chromeIntent =
          'intent://$host$path#Intent;scheme=https;package=com.android.chrome;end';

      try {
        final uri = Uri.parse(chromeIntent);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Chrome intent failed: $e');
      }

      final genericIntent =
          'intent://$host$path#Intent;scheme=https;action=android.intent.action.VIEW;end';
      try {
        final uri = Uri.parse(genericIntent);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Generic intent failed: $e');
      }
    } else if (isIOS) {
      try {
        if (await canLaunchUrl(currentUrl)) {
          await launchUrl(currentUrl, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('iOS redirect failed: $e');
      }
    }
  }

  Future<void> _copyLink() async {
    if (!kIsWeb) return;

    final currentUrl = web.window.location.href;

    try {
      await Clipboard.setData(ClipboardData(text: currentUrl));

      setState(() => _linkCopied = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _linkCopied = false);
      });
    } catch (e) {
      debugPrint('Clipboard copy failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to copy link to clipboard'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? PwaInstallerTheme.defaultTheme;
    final labels = widget.labels ?? const PwaInstallerLabels();
    final isIOS = PlatformDetection.isIos();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
          color:
              theme.backgroundGradient == null ? theme.backgroundColor : null,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: theme.contentPadding,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.logo != null) ...[
                      Center(child: widget.logo!),
                      const SizedBox(height: 24),
                    ],
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: theme.textColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🌐', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Open in',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: theme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextSpan(
                            text: ' Browser',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'For the best experience and to enable all features, please open this link in your default browser.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: theme.textColor,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildInstructions(context, theme, labels, isIOS),
                    const SizedBox(height: 24),
                    _buildButtons(context, theme, labels, isIOS),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, PwaInstallerTheme theme,
      PwaInstallerLabels labels, bool isIOS) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _attemptBrowserRedirect,
          icon: Icon(isIOS ? Icons.explore : Icons.open_in_browser,
              color: theme.accentColor),
          label: Text(
            isIOS ? 'Open in Safari' : 'Open in Chrome',
            style: TextStyle(
                color: theme.accentColor, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _copyLink,
          icon: Icon(
            _linkCopied ? Icons.check : Icons.copy,
            color: _linkCopied ? Colors.green : theme.secondaryTextColor,
            size: 20,
          ),
          label: Text(
            _linkCopied ? labels.linkCopied : labels.copyLink,
            style: TextStyle(
                color: _linkCopied ? Colors.green : theme.secondaryTextColor),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(
                color: theme.secondaryTextColor.withValues(alpha: 0.3)),
          ),
        ),
        if (widget.onDismiss != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onDismiss,
            child: Text('Continue anyway',
                style: TextStyle(color: theme.secondaryTextColor)),
          ),
        ],
      ],
    );
  }

  Widget _buildInstructions(BuildContext context, PwaInstallerTheme theme,
      PwaInstallerLabels labels, bool isIOS) {
    if (_detection.isInApp) {
      if (_detection.browserName.toLowerCase().contains('instagram')) {
        return _buildInstagramGuide(context, theme);
      }
      if (_detection.browserName.toLowerCase().contains('facebook')) {
        return _buildFacebookGuide(context, theme);
      }
    }
    return _buildGenericGuide(context, theme, isIOS);
  }

  Widget _buildInstagramGuide(BuildContext context, PwaInstallerTheme theme) {
    final isIOS = PlatformDetection.isIos();
    return _buildGuideContainer(
      context,
      theme,
      isIOS
          ? 'Tap the three dots (•••) in the top right corner'
          : 'Tap the three dots (⋮) in the top right corner',
      isIOS ? Icons.more_horiz : Icons.more_vert,
      isIOS ? 'Select "Open in Safari"' : 'Select "Open in Chrome"',
      isIOS ? Icons.explore : Icons.open_in_browser,
    );
  }

  Widget _buildFacebookGuide(BuildContext context, PwaInstallerTheme theme) {
    final isIOS = PlatformDetection.isIos();
    return _buildGuideContainer(
      context,
      theme,
      isIOS
          ? 'Tap the three dots (•••) in the bottom right corner'
          : 'Tap the three dots (⋮) in the top right corner',
      isIOS ? Icons.more_horiz : Icons.more_vert,
      isIOS ? 'Select "Open in Safari"' : 'Select "Open in external browser"',
      isIOS ? Icons.explore : Icons.open_in_browser,
    );
  }

  Widget _buildGenericGuide(
      BuildContext context, PwaInstallerTheme theme, bool isIOS) {
    return _buildGuideContainer(
      context,
      theme,
      'Look for a menu icon (⋮ or •••) in the app',
      Icons.more_vert,
      isIOS ? 'Select "Open in Safari"' : 'Select "Open in Chrome"',
      isIOS ? Icons.explore : Icons.open_in_browser,
    );
  }

  Widget _buildGuideContainer(
      BuildContext context,
      PwaInstallerTheme theme,
      String step1Text,
      IconData step1Icon,
      String step2Text,
      IconData step2Icon) {
    return Container(
      decoration: BoxDecoration(
        color: theme.darkSurfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInstructionStep(context, theme, step1Text, step1Icon),
          Divider(
              height: 1,
              color: theme.secondaryTextColor.withValues(alpha: 0.2)),
          _buildInstructionStep(context, theme, step2Text, step2Icon),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(BuildContext context, PwaInstallerTheme theme,
      String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
              child: Text(text,
                  style: TextStyle(color: theme.textColor, fontSize: 14))),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.accentColor, size: 20),
          ),
        ],
      ),
    );
  }
}
