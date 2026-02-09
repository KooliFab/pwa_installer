import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Detection result for in-app browser detection.
class InAppBrowserDetection {
  /// Whether the browser is an in-app browser
  final bool isInApp;

  /// Name of the detected in-app browser (e.g., 'Instagram', 'Facebook')
  final String browserName;

  const InAppBrowserDetection({
    required this.isInApp,
    required this.browserName,
  });

  @override
  String toString() =>
      'InAppBrowserDetection(isInApp: $isInApp, browserName: $browserName)';
}

/// Service responsible for detecting platform, browser, and PWA status.
///
/// This service provides comprehensive detection for:
/// - In-app browsers (Instagram, Facebook, TikTok, etc.)
/// - Platform detection (iOS, Android, Desktop)
/// - PWA installation status
/// - Safari version detection (including iOS 26+ Liquid Glass design)
class PlatformDetection {
  PlatformDetection._();

  /// Cached user agent string
  static String? _cachedUserAgent;

  /// Override user agent for testing purposes.
  ///
  /// Set this to a custom user agent string to test platform detection
  /// logic without running in an actual browser environment.
  ///
  /// Example:
  /// ```dart
  /// // In your test setup
  /// PlatformDetection.userAgentOverride = 'Instagram 123.0 (iPhone; iOS 17.0)';
  ///
  /// // In your test teardown
  /// PlatformDetection.resetUserAgentOverride();
  /// ```
  @visibleForTesting
  static String? userAgentOverride;

  /// Resets the user agent override and clears the cache.
  ///
  /// Call this in test teardown to ensure clean state between tests.
  @visibleForTesting
  static void resetUserAgentOverride() {
    userAgentOverride = null;
    _cachedUserAgent = null;
  }

  /// Gets the user agent string, caching it for performance.
  ///
  /// If [userAgentOverride] is set (for testing), returns that value instead.
  static String get _userAgent {
    // Allow testing override
    if (userAgentOverride != null) {
      return userAgentOverride!.toLowerCase();
    }
    if (!kIsWeb) return '';
    _cachedUserAgent ??= web.window.navigator.userAgent.toLowerCase();
    return _cachedUserAgent!;
  }

  /// Detects if the current browser is an in-app browser.
  ///
  /// Supports detection of:
  /// - Instagram
  /// - Facebook / Messenger (FBAN, FBAV)
  /// - LinkedIn
  /// - Twitter / X
  /// - TikTok
  /// - Snapchat
  /// - WhatsApp
  /// - Line
  /// - WeChat (MicroMessenger)
  ///
  /// Returns [InAppBrowserDetection] with detected browser name.
  static InAppBrowserDetection detectInAppBrowser() {
    if (!kIsWeb) {
      return const InAppBrowserDetection(isInApp: false, browserName: 'Native');
    }

    final ua = _userAgent;

    // Instagram in-app browser
    if (ua.contains('instagram')) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'Instagram');
    }

    // Facebook/Messenger in-app browser (FBAN = Facebook App, FBAV = Facebook App Version)
    if (ua.contains('fban') || ua.contains('fbav')) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'Facebook');
    }

    // LinkedIn in-app browser
    if (ua.contains('linkedinapp')) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'LinkedIn');
    }

    // Twitter/X in-app browser
    if (ua.contains('twitter')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'Twitter');
    }

    // TikTok in-app browser
    if (ua.contains('musical_ly') || ua.contains('tiktok')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'TikTok');
    }

    // Snapchat in-app browser
    if (ua.contains('snapchat')) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'Snapchat');
    }

    // WhatsApp in-app browser
    if (ua.contains('whatsapp')) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'WhatsApp');
    }

    // Line in-app browser
    if (ua.contains('line/')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'Line');
    }

    // WeChat in-app browser
    if (ua.contains('micromessenger')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'WeChat');
    }

    // Slack in-app browser
    if (ua.contains('slack')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'Slack');
    }

    // Discord in-app browser
    if (ua.contains('discord')) {
      return const InAppBrowserDetection(isInApp: true, browserName: 'Discord');
    }

    // Generic Android WebView detection
    if (ua.contains('android') &&
        (ua.contains('; wv)') || ua.contains(';wv)'))) {
      return const InAppBrowserDetection(
          isInApp: true, browserName: 'In-App Browser');
    }

    return const InAppBrowserDetection(isInApp: false, browserName: 'Standard');
  }

  /// Determines if the current browser is Safari on iOS.
  static bool isIosSafari() {
    if (!kIsWeb) return false;

    final ua = _userAgent;
    final isIos =
        ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
    final isSafari = ua.contains('safari') && !ua.contains('chrome');

    return isIos && isSafari;
  }

  /// Determines if the current browser is on an iOS device.
  static bool isIos() {
    if (!kIsWeb) return false;

    final ua = _userAgent;
    return ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
  }

  /// Determines if the current browser is on an Android device.
  static bool isAndroid() {
    if (!kIsWeb) return false;
    return _userAgent.contains('android');
  }

  /// Determines if the current browser is Chrome on Android.
  static bool isAndroidChrome() {
    if (!kIsWeb) return false;

    final ua = _userAgent;
    return ua.contains('android') && ua.contains('chrome');
  }

  /// Determines if the current environment is a desktop browser.
  static bool isDesktop() {
    if (!kIsWeb) return false;
    return !isIos() && !isAndroid();
  }

  /// Extracts the iOS version from the user agent string.
  ///
  /// Returns null if not an iOS device or version cannot be parsed.
  /// Example: For "OS 18_0" returns 18.0
  static double? getIosVersion() {
    if (!kIsWeb) return null;

    try {
      final ua = web.window.navigator.userAgent;
      final regex = RegExp(r'OS (\d+)_(\d+)_?(\d+)? like Mac OS X');
      final match = regex.firstMatch(ua);

      if (match != null && match.groupCount >= 2) {
        final major = match.group(1);
        final minor = match.group(2);
        return double.parse('$major.$minor');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting iOS version: $e');
      return null;
    }
  }

  /// Extracts the Safari browser version from the user agent string.
  ///
  /// Note: Safari version and iOS version have diverged starting iOS 18.6+
  /// Safari 26+ uses the new "Liquid Glass" design.
  ///
  /// Returns null if Safari version cannot be parsed.
  static double? getSafariVersion() {
    if (!kIsWeb) return null;

    try {
      final ua = web.window.navigator.userAgent;
      final regex = RegExp(r'Version/(\d+)\.(\d+)');
      final match = regex.firstMatch(ua);

      if (match != null && match.groupCount >= 2) {
        final major = match.group(1);
        final minor = match.group(2);
        return double.parse('$major.$minor');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting Safari version: $e');
      return null;
    }
  }

  /// Determines if the current browser is Safari 26 or newer.
  ///
  /// Safari 26+ (available on iOS 18.6+) features the new "Liquid Glass"
  /// design with a floating address bar and different UI layout.
  static bool isSafari26OrNewer() {
    if (!isIosSafari()) return false;

    final safariVersion = getSafariVersion();
    if (safariVersion != null && safariVersion >= 26) {
      return true;
    }
    return false;
  }

  /// Determines if the current app is running as an installed PWA.
  ///
  /// Checks multiple conditions:
  /// - `display-mode: standalone` media query
  /// - `display-mode: fullscreen` media query
  /// - `window.navigator.standalone` (iOS specific)
  static bool isInstalledPwa() {
    if (!kIsWeb) return false;

    try {
      final displayModeStandalone =
          web.window.matchMedia('(display-mode: standalone)');
      final displayModeFullscreen =
          web.window.matchMedia('(display-mode: fullscreen)');

      if (displayModeStandalone.matches || displayModeFullscreen.matches) {
        return true;
      }

      if (isIosSafari()) {
        final standalone = _checkIosStandalone();
        if (standalone) return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error detecting PWA status: $e');
      return false;
    }
  }

  /// Checks the iOS-specific `window.navigator.standalone` property.
  static bool _checkIosStandalone() {
    try {
      final navigator = web.window.navigator;
      final standaloneValue = (navigator as dynamic).standalone;
      return standaloneValue == true;
    } catch (e) {
      return false;
    }
  }

  /// Determines if the app should show the install guide.
  ///
  /// Returns true if:
  /// - Running in a web browser (not installed as PWA)
  /// - Running on a mobile device (iOS Safari, Android Chrome, or in-app browser)
  static bool shouldShowInstallGuide() {
    if (!kIsWeb) return false;
    if (isInstalledPwa()) return false;
    return isMobile();
  }

  /// Determines if the current device is a mobile device.
  ///
  /// Returns true if running on iOS or Android.
  static bool isMobile() {
    if (!kIsWeb) return false;
    return isIos() || isAndroid();
  }

  /// Determines if the app should show the desktop install guide.
  ///
  /// Returns true if:
  /// - Running on a desktop browser (not mobile)
  /// - Not already installed as PWA
  static bool shouldShowDesktopInstallGuide() {
    if (!kIsWeb) return false;
    if (isInstalledPwa()) return false;
    return isDesktop();
  }
}
