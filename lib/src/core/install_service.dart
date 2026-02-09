import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'platform_detection.dart';
import 'browser_redirect.dart';

export 'platform_detection.dart';

/// JS interop for accessing the early-captured beforeinstallprompt event.
/// This is set by a script in index.html before Flutter loads.
@JS('__pwaInstallPrompt')
external JSAny? get _earlyPwaInstallPrompt;

/// Extension type for BeforeInstallPromptEvent which adds the prompt() method.
/// This event is not in the web package, so we define our own interop.
extension type _BeforeInstallPromptEvent._(JSObject _) implements web.Event {
  external void prompt();
}

/// Manages PWA installation prompts, browser detection, and PWA status.
///
/// This class provides a singleton instance that handles:
/// - Intercepting `beforeinstallprompt` events for custom install UI
/// - Triggering the browser's native install prompt
/// - Detecting in-app browsers (Instagram, Facebook, etc.)
/// - Checking PWA installation status
///
/// ## Usage
///
/// Initialize early in your app lifecycle:
/// ```dart
/// void main() {
///   PwaInstall().init();
///   runApp(MyApp());
/// }
/// ```
///
/// Show custom install button when prompt is available:
/// ```dart
/// ValueListenableBuilder<bool>(
///   valueListenable: PwaInstall().installPromptEnabled,
///   builder: (context, enabled, _) {
///     if (!enabled) return SizedBox.shrink();
///     return ElevatedButton(
///       onPressed: () => PwaInstall().promptInstall(),
///       child: Text('Install App'),
///     );
///   },
/// )
/// ```
class PwaInstall {
  static final PwaInstall _instance = PwaInstall._internal();

  factory PwaInstall() {
    return _instance;
  }

  PwaInstall._internal();

  /// Event fired before the install prompt is shown.
  web.Event? _deferredPrompt;

  /// Notifies when the install prompt is ready to be shown.
  final ValueNotifier<bool> installPromptEnabled = ValueNotifier(false);

  /// Notifies when the PWA has been successfully installed.
  final ValueNotifier<bool> isInstalled = ValueNotifier(false);

  /// Initializes the PWA install listeners.
  ///
  /// Should be called early in the app lifecycle (e.g. main()).
  /// On non-web platforms, this is a no-op.
  ///
  /// [enableBrowserRedirect] - Whether to inject JavaScript-based browser redirect
  /// for in-app browsers. Defaults to true. Set to false to disable the redirect
  /// functionality entirely.
  ///
  /// [cspNonce] - Optional CSP nonce for apps using strict Content Security Policy.
  /// If your app has a CSP header with `script-src` that doesn't include
  /// `'unsafe-inline'`, pass the nonce value here to allow injected scripts to execute.
  void init({
    bool enableBrowserRedirect = true,
    String? cspNonce,
  }) {
    if (!kIsWeb) return;

    // Inject the browser redirect script only if enabled
    if (enableBrowserRedirect) {
      BrowserRedirectInjector.inject(nonce: cspNonce);
    }

    // Check if already running as installed PWA
    if (PlatformDetection.isInstalledPwa()) {
      isInstalled.value = true;
      debugPrint('PWA is already installed');
      return;
    }

    // Listen for beforeinstallprompt event
    web.window.addEventListener(
        'beforeinstallprompt',
        (web.Event event) {
          // Stash the event so it can be triggered later
          _deferredPrompt = event;
          // Update UI to notify the user they can install the PWA
          installPromptEnabled.value = true;
          debugPrint('beforeinstallprompt event fired');
        }.toJS);

    // Listen for appinstalled event
    web.window.addEventListener(
        'appinstalled',
        (web.Event event) {
          // Clear the deferredPrompt so it can be garbage collected
          _deferredPrompt = null;
          installPromptEnabled.value = false;
          isInstalled.value = true;
          debugPrint('PWA was installed');
        }.toJS);

    // Chrome often fires beforeinstallprompt during initial page load, before
    // Flutter's JS has initialised and this listener is attached.  A script in
    // index.html captures it early and stores it on window.__pwaInstallPrompt.
    // Recover it here so the install button can be shown immediately.
    final earlyPrompt = _earlyPwaInstallPrompt;
    if (earlyPrompt != null) {
      _deferredPrompt = _BeforeInstallPromptEvent._(earlyPrompt as JSObject);
      installPromptEnabled.value = true;
      debugPrint('beforeinstallprompt: recovered from pre-Flutter capture');
    }
  }

  /// Triggers the browser's install prompt.
  ///
  /// This should only be called when [installPromptEnabled] is true.
  /// After calling this, the prompt will be cleared regardless of user choice.
  ///
  /// Returns a [Future] that completes when the prompt is shown.
  Future<void> promptInstall() async {
    final prompt = _deferredPrompt;
    if (prompt != null) {
      // Show the install prompt using typed js_interop
      (_BeforeInstallPromptEvent._(prompt as JSObject)).prompt();

      // Clear the prompt after use
      _deferredPrompt = null;
      installPromptEnabled.value = false;

      debugPrint('Install prompt shown');
    }
  }

  /// Checks if the app is running inside a known in-app browser.
  ///
  /// Supported browsers: Instagram, Facebook, LinkedIn, Twitter,
  /// TikTok, Snapchat, WhatsApp, Line, WeChat, Slack.
  ///
  /// For more detailed information, use [detectInAppBrowser].
  bool isInAppBrowser() {
    return PlatformDetection.detectInAppBrowser().isInApp;
  }

  /// Detects in-app browser with detailed information.
  ///
  /// Returns [InAppBrowserDetection] containing:
  /// - [isInApp]: Whether running in an in-app browser
  /// - [browserName]: Name of the detected browser (e.g., 'Instagram')
  InAppBrowserDetection detectInAppBrowser() {
    return PlatformDetection.detectInAppBrowser();
  }

  /// Checks if the app is running as an installed PWA.
  ///
  /// Returns true if the app was added to the home screen and is
  /// running in standalone mode.
  bool isInstalledPwa() {
    return PlatformDetection.isInstalledPwa();
  }

  /// Checks if the install guide should be shown.
  ///
  /// Returns true if:
  /// - Running on mobile (iOS Safari or Android Chrome)
  /// - Not already installed as PWA
  bool shouldShowInstallGuide() {
    return PlatformDetection.shouldShowInstallGuide();
  }

  /// Checks if the current device is a mobile device.
  ///
  /// Returns true if running on iOS or Android.
  bool isMobile() {
    return PlatformDetection.isMobile();
  }

  /// Checks if the desktop install guide should be shown.
  ///
  /// Returns true if:
  /// - Running on a desktop browser (not mobile)
  /// - Not already installed as PWA
  ///
  /// Use this to redirect desktop users to a screen showing a QR code
  /// that they can scan with their mobile device.
  bool shouldShowDesktopInstallGuide() {
    return PlatformDetection.shouldShowDesktopInstallGuide();
  }
}
