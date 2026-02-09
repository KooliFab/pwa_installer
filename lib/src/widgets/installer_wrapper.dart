import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/install_service.dart';
import '../core/browser_redirect.dart';
import '../theme/theme.dart';
import '../theme/labels.dart';
import 'in_app_browser_guide.dart';
import 'mobile_install_guide.dart';
import 'desktop_install_guide.dart';

/// Configuration stored by [PwaInstaller.init].
class _PwaInstallerConfig {
  final bool enableBrowserRedirect;
  final bool enableDesktopInstallGuide;
  final bool enableMobileInstallGuide;
  final bool forceInstall;

  const _PwaInstallerConfig({
    this.enableBrowserRedirect = true,
    this.enableDesktopInstallGuide = true,
    this.enableMobileInstallGuide = true,
    this.forceInstall = false,
  });
}

/// A unified PWA installation handler for Flutter web apps.
///
/// Provides:
/// - In-app browser detection and redirection (Instagram, Facebook, etc.)
/// - Desktop install guide with QR code
/// - Mobile install guide for iOS Safari and Android Chrome
/// - PWA install prompt handling
///
/// ## Usage
///
/// ```dart
/// void main() {
///   PwaInstaller.init(
///     enableBrowserRedirect: true,
///     enableMobileInstallGuide: true,
///     enableDesktopInstallGuide: false,
///   );
///
///   runApp(
///     MaterialApp(
///       home: PwaInstaller(
///         logo: Image.asset('assets/logo.png'),
///         appName: 'My App',
///         child: MyHomePage(),
///       ),
///     ),
///   );
/// }
/// ```
class PwaInstaller extends StatefulWidget {
  /// Logo widget to display on install screens.
  final Widget? logo;

  /// App name to display on install screens.
  final String? appName;

  /// Theme for install screens.
  final PwaInstallerTheme theme;

  /// Labels for install screens (for i18n).
  final PwaInstallerLabels labels;

  /// Custom widget for in-app browser redirection.
  final Widget Function(BuildContext context, VoidCallback onDismiss)?
      customBrowserRedirectScreen;

  /// Custom widget for desktop install guide.
  final Widget Function(BuildContext context, VoidCallback onDismiss)?
      customDesktopScreen;

  /// Custom widget for mobile install guide.
  final Widget Function(BuildContext context, VoidCallback onDismiss)?
      customMobileScreen;

  /// The main app to show when no PWA screen is needed.
  final Widget child;

  const PwaInstaller({
    super.key,
    this.logo,
    this.appName,
    this.theme = const PwaInstallerTheme(),
    this.labels = const PwaInstallerLabels(),
    this.customBrowserRedirectScreen,
    this.customDesktopScreen,
    this.customMobileScreen,
    required this.child,
  });

  static _PwaInstallerConfig _config = const _PwaInstallerConfig();
  static bool _initialized = false;

  /// Initializes PWA installer with enable flags.
  ///
  /// This should be called early in your app lifecycle (e.g., in main())
  /// before runApp(). On non-web platforms, this is a no-op.
  ///
  /// **Note:** Calling this method multiple times is allowed but will log a
  /// warning. The new configuration will be used, but this may indicate a bug
  /// in your code (e.g., calling init() in a widget's build method).
  ///
  /// [enableBrowserRedirect] - Whether to detect and redirect users out of
  /// in-app browsers (Instagram, Facebook, etc.) before prompting install.
  /// Defaults to true.
  ///
  /// [enableDesktopInstallGuide] - Whether to show a QR code screen for
  /// desktop users, so they can scan and install the PWA on mobile.
  /// Defaults to true.
  ///
  /// [enableMobileInstallGuide] - Whether to show the platform-specific
  /// install guide (iOS Safari share sheet steps / Android Chrome steps).
  /// Defaults to true.
  ///
  /// [forceInstall] - Whether to block the app until the user installs the
  /// PWA. When true, the dismiss button is hidden on all install screens.
  /// Defaults to false.
  ///
  /// [cspNonce] - Optional CSP nonce for apps using strict Content Security Policy.
  /// If your app has a CSP header with `script-src` that doesn't include
  /// `'unsafe-inline'`, pass the nonce value here to allow injected scripts to execute.
  ///
  /// **Setup:** For the install prompt to be reliably caught on Android Chrome,
  /// add the following early-capture script to your app's `index.html` before
  /// the Flutter bootstrap:
  /// ```html
  /// <script>
  ///   window.addEventListener('beforeinstallprompt', (e) => {
  ///     window.__pwaInstallPrompt = e;
  ///   });
  /// </script>
  /// ```
  static void init({
    bool enableBrowserRedirect = true,
    bool enableDesktopInstallGuide = true,
    bool enableMobileInstallGuide = true,
    bool forceInstall = false,
    String? cspNonce,
  }) {
    if (!kIsWeb) return;

    // Warn if re-initializing, as this may indicate a bug
    if (_initialized) {
      debugPrint(
        'PwaInstaller.init() called multiple times. '
        'Using new configuration. If this is unexpected, ensure init() '
        'is only called once (e.g., in main() before runApp()).',
      );
    }

    _config = _PwaInstallerConfig(
      enableBrowserRedirect: enableBrowserRedirect,
      enableDesktopInstallGuide: enableDesktopInstallGuide,
      enableMobileInstallGuide: enableMobileInstallGuide,
      forceInstall: forceInstall,
    );

    if (enableBrowserRedirect) {
      BrowserRedirectInjector.inject(nonce: cspNonce);
    }

    PwaInstall().init(
        enableBrowserRedirect: enableBrowserRedirect,
        cspNonce: cspNonce);
    _initialized = true;
  }

  /// Whether [init] has been called.
  static bool get isInitialized => _initialized;

  /// Checks if running inside an in-app browser.
  static bool isInAppBrowser() => PwaInstall().isInAppBrowser();

  /// Detects in-app browser with detailed info.
  static InAppBrowserDetection detectInAppBrowser() =>
      PwaInstall().detectInAppBrowser();

  /// Checks if running as an installed PWA.
  static bool isInstalledPwa() => PwaInstall().isInstalledPwa();

  /// Checks if mobile install guide should be shown.
  static bool shouldShowInstallGuide() => PwaInstall().shouldShowInstallGuide();

  /// Checks if desktop install guide should be shown.
  static bool shouldShowDesktopInstallGuide() =>
      PwaInstall().shouldShowDesktopInstallGuide();

  /// Checks if the device is mobile.
  static bool isMobile() => PwaInstall().isMobile();

  /// Triggers the browser's install prompt.
  static Future<void> promptInstall() => PwaInstall().promptInstall();

  /// Notifies when install prompt is ready.
  static ValueNotifier<bool> get installPromptEnabled =>
      PwaInstall().installPromptEnabled;

  /// Notifies when PWA has been installed.
  static ValueNotifier<bool> get isInstalled => PwaInstall().isInstalled;

  @override
  State<PwaInstaller> createState() => _PwaInstallerState();
}

class _PwaInstallerState extends State<PwaInstaller> {
  bool _dismissed = false;

  void _onDismiss() {
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return widget.child;

    final config = PwaInstaller._config;
    final VoidCallback? dismissCallback =
        config.forceInstall ? null : _onDismiss;

    // 1. In-app browser check
    if (config.enableBrowserRedirect && PwaInstaller.isInAppBrowser()) {
      if (widget.customBrowserRedirectScreen != null) {
        // Remove the JS overlay so the custom Flutter screen is visible
        BrowserRedirectInjector.removeOverlay();
        return widget.customBrowserRedirectScreen!(context, _onDismiss);
      }

      if (BrowserRedirectInjector.isOverlayShown()) return widget.child;
      return InAppBrowserGuide(
        logo: widget.logo,
        theme: widget.theme,
        labels: widget.labels,
        onDismiss: dismissCallback,
      );
    }

    // 2. Desktop install guide
    if (config.enableDesktopInstallGuide &&
        PwaInstaller.shouldShowDesktopInstallGuide()) {
      if (widget.customDesktopScreen != null) {
        return widget.customDesktopScreen!(context, _onDismiss);
      }
      return DesktopInstallGuide(
        logo: widget.logo,
        appName: widget.appName,
        theme: widget.theme,
        labels: widget.labels,
        onDismiss: dismissCallback,
      );
    }

    // 3. Mobile install guide
    if (config.enableMobileInstallGuide &&
        PwaInstaller.shouldShowInstallGuide()) {
      if (widget.customMobileScreen != null) {
        return widget.customMobileScreen!(context, _onDismiss);
      }
      return MobileInstallGuide(
        logo: widget.logo,
        theme: widget.theme,
        labels: widget.labels,
        onDismiss: dismissCallback,
      );
    }

    // 4. Normal app
    return widget.child;
  }
}
