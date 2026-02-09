/// PWA Installer - A Flutter package to facilitate PWA installation
/// and handle in-app browsers.
///
/// This package provides:
/// - PWA install prompt interception for custom install UI
/// - In-app browser detection (Instagram, Facebook, TikTok, etc.)
/// - Platform-specific install guide widgets
/// - Force browser redirect screens
/// - iOS 26+ (Liquid Glass) Safari support
library pwa_installer;

// Core
export 'src/core/platform_detection.dart';

// Theme
export 'src/theme/theme.dart';
export 'src/theme/labels.dart';

// Widgets
export 'src/widgets/installer_wrapper.dart';
export 'src/widgets/in_app_browser_guide.dart';
export 'src/widgets/mobile_install_guide.dart';
export 'src/widgets/desktop_install_guide.dart';
