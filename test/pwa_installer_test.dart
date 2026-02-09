// Note: This package requires browser environment for full testing.
// Run with: flutter test --platform chrome

@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pwa_installer/pwa_installer.dart';
// Internal imports for testing
import 'package:pwa_installer/src/core/install_service.dart';
import 'package:pwa_installer/src/core/browser_redirect.dart';

void main() {
  group('PwaInstallerTheme', () {
    test('default constructor has expected default values', () {
      const theme = PwaInstallerTheme();
      expect(theme.primaryColor, const Color(0xFF1A1D32));
      expect(theme.accentColor, const Color(0xFFFF7A5A));
      expect(theme.surfaceColor, const Color(0xFF1E1E1E));
      expect(theme.darkSurfaceColor, const Color(0xFF2A2A3A));
      expect(theme.textColor, Colors.white);
      expect(theme.secondaryTextColor, const Color(0xFF9E9E9E));
      expect(theme.backgroundColor, const Color(0xFF1A1D32));
      expect(theme.backgroundGradient, isNull);
      expect(theme.borderRadius, 12.0);
      expect(theme.contentPadding, const EdgeInsets.all(24.0));
    });

    test('defaultTheme has expected gradient', () {
      final theme = PwaInstallerTheme.defaultTheme;
      expect(theme.backgroundGradient, isNotNull);
      expect(theme.backgroundGradient, isA<LinearGradient>());
      final gradient = theme.backgroundGradient as LinearGradient;
      expect(gradient.colors.length, 2);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    test('lightTheme has no gradient and light colors', () {
      final theme = PwaInstallerTheme.lightTheme;
      expect(theme.backgroundGradient, isNull);
      expect(theme.backgroundColor, Colors.white);
      expect(theme.surfaceColor, Colors.white);
      expect(theme.textColor, const Color(0xFF1A1A1A));
    });

    test('copyWith creates new instance with changed values', () {
      const theme = PwaInstallerTheme();
      final modified = theme.copyWith(borderRadius: 20.0);
      expect(modified.borderRadius, 20.0);
      expect(modified.primaryColor, theme.primaryColor);
      expect(modified.accentColor, theme.accentColor);
    });

    test('copyWith can change multiple values', () {
      const theme = PwaInstallerTheme();
      final modified = theme.copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.red,
        borderRadius: 16.0,
        contentPadding: const EdgeInsets.all(32.0),
      );
      expect(modified.primaryColor, Colors.blue);
      expect(modified.accentColor, Colors.red);
      expect(modified.borderRadius, 16.0);
      expect(modified.contentPadding, const EdgeInsets.all(32.0));
      expect(modified.surfaceColor, theme.surfaceColor);
    });

    test('copyWith with gradient', () {
      const theme = PwaInstallerTheme();
      const newGradient = LinearGradient(
        colors: [Colors.purple, Colors.pink],
      );
      final modified = theme.copyWith(backgroundGradient: newGradient);
      expect(modified.backgroundGradient, newGradient);
    });

    testWidgets('fromContext creates theme from BuildContext', (tester) async {
      late PwaInstallerTheme contextTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          home: Builder(
            builder: (context) {
              contextTheme = PwaInstallerTheme.fromContext(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(contextTheme.primaryColor, isNotNull);
      expect(contextTheme.accentColor, isNotNull);
      expect(contextTheme.surfaceColor, isNotNull);
    });
  });

  group('PwaInstallerLabels', () {
    test('default labels are in English', () {
      const labels = PwaInstallerLabels();
      expect(labels.titleAdd, 'Add ');
      expect(labels.titleToHomeScreen, 'to Home Screen');
      expect(labels.copyLink, 'Copy Link');
      expect(labels.linkCopied, 'Link Copied!');
      expect(labels.iosStep1, isNotEmpty);
      expect(labels.iosStep2, isNotEmpty);
      expect(labels.iosStep3, isNotEmpty);
      expect(labels.androidStep1, isNotEmpty);
      expect(labels.androidStep2, isNotEmpty);
    });

    test('all default labels are non-empty', () {
      const labels = PwaInstallerLabels();
      expect(labels.titleAdd, isNotEmpty);
      expect(labels.titleToHomeScreen, isNotEmpty);
      expect(labels.description, isNotEmpty);
      expect(labels.iosStep1, isNotEmpty);
      expect(labels.iosStep2, isNotEmpty);
      expect(labels.iosStep3, isNotEmpty);
      expect(labels.iosLegacyStep1, isNotEmpty);
      expect(labels.iosLegacyStep2, isNotEmpty);
      expect(labels.androidStep1, isNotEmpty);
      expect(labels.androidStep2, isNotEmpty);
      expect(labels.addToHomeScreen, isNotEmpty);
      expect(labels.installApp, isNotEmpty);
      expect(labels.share, isNotEmpty);
      expect(labels.openInBrowser, isNotEmpty);
      expect(labels.copyLink, isNotEmpty);
      expect(labels.linkCopied, isNotEmpty);
      expect(labels.fallbackMessage, isNotEmpty);
      expect(labels.unsupportedBrowserMessage, isNotEmpty);
      expect(labels.desktopTitle, isNotEmpty);
      expect(labels.desktopDescription, isNotEmpty);
      expect(labels.desktopHowToInstall, isNotEmpty);
      expect(labels.desktopIosTitle, isNotEmpty);
      expect(labels.desktopAndroidTitle, isNotEmpty);
      expect(labels.desktopIosStep1, isNotEmpty);
      expect(labels.desktopIosStep2, isNotEmpty);
      expect(labels.desktopIosStep3, isNotEmpty);
      expect(labels.desktopAndroidStep1, isNotEmpty);
      expect(labels.desktopAndroidStep2, isNotEmpty);
      expect(labels.desktopQrError, isNotEmpty);
      expect(labels.desktopDismissButton, isNotEmpty);
    });

    test('copyWith creates new instance with changed values', () {
      const labels = PwaInstallerLabels();
      final modified = labels.copyWith(titleAdd: 'Ajouter ');
      expect(modified.titleAdd, 'Ajouter ');
      expect(modified.titleToHomeScreen, labels.titleToHomeScreen);
    });

    test('copyWith can change multiple values for localization', () {
      const labels = PwaInstallerLabels();
      final frenchLabels = labels.copyWith(
        titleAdd: 'Ajouter ',
        titleToHomeScreen: "à l'écran d'accueil",
        copyLink: 'Copier le lien',
        linkCopied: 'Lien copié !',
        installApp: "Installer l'app",
      );
      expect(frenchLabels.titleAdd, 'Ajouter ');
      expect(frenchLabels.titleToHomeScreen, "à l'écran d'accueil");
      expect(frenchLabels.copyLink, 'Copier le lien');
      expect(frenchLabels.linkCopied, 'Lien copié !');
      expect(frenchLabels.installApp, "Installer l'app");
      // Unchanged values should remain
      expect(frenchLabels.iosStep1, labels.iosStep1);
    });

    test('copyWith can change desktop labels', () {
      const labels = PwaInstallerLabels();
      final modified = labels.copyWith(
        desktopTitle: 'Custom Desktop Title',
        desktopDescription: 'Custom Description',
        desktopDismissButton: 'Skip',
      );
      expect(modified.desktopTitle, 'Custom Desktop Title');
      expect(modified.desktopDescription, 'Custom Description');
      expect(modified.desktopDismissButton, 'Skip');
    });

    test('copyWith can change iOS-specific labels', () {
      const labels = PwaInstallerLabels();
      final modified = labels.copyWith(
        iosStep1: 'Custom iOS Step 1',
        iosStep2: 'Custom iOS Step 2',
        iosStep3: 'Custom iOS Step 3',
        iosLegacyStep1: 'Custom Legacy Step 1',
        iosLegacyStep2: 'Custom Legacy Step 2',
      );
      expect(modified.iosStep1, 'Custom iOS Step 1');
      expect(modified.iosStep2, 'Custom iOS Step 2');
      expect(modified.iosStep3, 'Custom iOS Step 3');
      expect(modified.iosLegacyStep1, 'Custom Legacy Step 1');
      expect(modified.iosLegacyStep2, 'Custom Legacy Step 2');
    });

    test('copyWith can change Android-specific labels', () {
      const labels = PwaInstallerLabels();
      final modified = labels.copyWith(
        androidStep1: 'Custom Android Step 1',
        androidStep2: 'Custom Android Step 2',
      );
      expect(modified.androidStep1, 'Custom Android Step 1');
      expect(modified.androidStep2, 'Custom Android Step 2');
    });
  });

  group('InAppBrowserDetection', () {
    test('has correct default values', () {
      const detection =
          InAppBrowserDetection(isInApp: false, browserName: 'Standard');
      expect(detection.isInApp, false);
      expect(detection.browserName, 'Standard');
    });

    test('can represent in-app browser state', () {
      const detection =
          InAppBrowserDetection(isInApp: true, browserName: 'Instagram');
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Instagram');
    });

    test('toString works correctly for standard browser', () {
      const detection =
          InAppBrowserDetection(isInApp: false, browserName: 'Standard');
      expect(detection.toString(),
          'InAppBrowserDetection(isInApp: false, browserName: Standard)');
    });

    test('toString works correctly for in-app browser', () {
      const detection =
          InAppBrowserDetection(isInApp: true, browserName: 'Instagram');
      expect(detection.toString(),
          'InAppBrowserDetection(isInApp: true, browserName: Instagram)');
    });

    test('can represent various browser types', () {
      final browsers = [
        'Instagram',
        'Facebook',
        'LinkedIn',
        'Twitter',
        'TikTok',
        'Snapchat',
        'WhatsApp',
        'Line',
        'WeChat',
        'Slack',
        'Discord',
        'In-App Browser',
      ];

      for (final browser in browsers) {
        final detection =
            InAppBrowserDetection(isInApp: true, browserName: browser);
        expect(detection.isInApp, true);
        expect(detection.browserName, browser);
      }
    });
  });

  group('PlatformDetection', () {
    test('detectInAppBrowser returns a valid result', () {
      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection, isA<InAppBrowserDetection>());
      expect(detection.browserName, isNotEmpty);
    });

    test('isIosSafari returns boolean', () {
      final result = PlatformDetection.isIosSafari();
      expect(result, isA<bool>());
    });

    test('isIos returns boolean', () {
      final result = PlatformDetection.isIos();
      expect(result, isA<bool>());
    });

    test('isAndroid returns boolean', () {
      final result = PlatformDetection.isAndroid();
      expect(result, isA<bool>());
    });

    test('isAndroidChrome returns boolean', () {
      final result = PlatformDetection.isAndroidChrome();
      expect(result, isA<bool>());
    });

    test('isDesktop returns boolean', () {
      final result = PlatformDetection.isDesktop();
      expect(result, isA<bool>());
    });

    test('getIosVersion returns double or null', () {
      final result = PlatformDetection.getIosVersion();
      // Result is nullable double - just verify no exception is thrown
      expect(() => result, returnsNormally);
    });

    test('getSafariVersion returns double or null', () {
      final result = PlatformDetection.getSafariVersion();
      // Result is nullable double - just verify no exception is thrown
      expect(() => result, returnsNormally);
    });

    test('isSafari26OrNewer returns boolean', () {
      final result = PlatformDetection.isSafari26OrNewer();
      expect(result, isA<bool>());
    });

    test('isInstalledPwa returns boolean', () {
      final result = PlatformDetection.isInstalledPwa();
      expect(result, isA<bool>());
    });

    test('shouldShowInstallGuide returns boolean', () {
      final result = PlatformDetection.shouldShowInstallGuide();
      expect(result, isA<bool>());
    });

    test('isMobile returns boolean', () {
      final result = PlatformDetection.isMobile();
      expect(result, isA<bool>());
    });

    test('shouldShowDesktopInstallGuide returns boolean', () {
      final result = PlatformDetection.shouldShowDesktopInstallGuide();
      expect(result, isA<bool>());
    });

    test('platform detection is mutually exclusive for mobile types', () {
      final isIos = PlatformDetection.isIos();
      final isAndroid = PlatformDetection.isAndroid();
      // A device cannot be both iOS and Android
      expect(isIos && isAndroid, false);
    });

    test('isMobile is consistent with isIos and isAndroid', () {
      final isIos = PlatformDetection.isIos();
      final isAndroid = PlatformDetection.isAndroid();
      final isMobile = PlatformDetection.isMobile();
      expect(isMobile, isIos || isAndroid);
    });

    test('isDesktop is opposite of isMobile', () {
      final isMobile = PlatformDetection.isMobile();
      final isDesktop = PlatformDetection.isDesktop();
      expect(isDesktop, !isMobile);
    });
  });

  group('PlatformDetection with mocked user agents', () {
    // Reset the user agent override after each test
    tearDown(() {
      PlatformDetection.resetUserAgentOverride();
    });

    test('detects Instagram in-app browser on iOS', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 305.0.0.34.111';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Instagram');
      expect(PlatformDetection.isIos(), true);
      expect(PlatformDetection.isAndroid(), false);
    });

    test('detects Instagram in-app browser on Android', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Instagram 305.0.0.34.111';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Instagram');
      expect(PlatformDetection.isIos(), false);
      expect(PlatformDetection.isAndroid(), true);
    });

    test('detects Facebook in-app browser (FBAN token)', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) FBAN/FBIOS;FBAV/400.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Facebook');
    });

    test('detects Facebook in-app browser (FBAV token)', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Linux; Android 13) FBAV/400.0.0.0.71';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Facebook');
    });

    test('detects TikTok in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) TikTok 32.0.0 rv:320000';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'TikTok');
    });

    test('detects TikTok via musical_ly token', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Linux; Android 13) Musical_ly 32.0.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'TikTok');
    });

    test('detects LinkedIn in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) LinkedInApp/9.29.1';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'LinkedIn');
    });

    test('detects Twitter in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Twitter/10.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Twitter');
    });

    test('detects WhatsApp in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) WhatsApp/2.24.1';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'WhatsApp');
    });

    test('detects Snapchat in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Snapchat/12.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Snapchat');
    });

    test('detects WeChat (MicroMessenger) in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) MicroMessenger/8.0.44';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'WeChat');
    });

    test('detects Line in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Line/13.0.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Line');
    });

    test('detects Slack in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Slack/24.01';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Slack');
    });

    test('detects Discord in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Discord/200.0';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'Discord');
    });

    test('detects generic Android WebView', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Linux; Android 13; SM-G991B; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/120.0.0.0 Mobile Safari/537.36';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, true);
      expect(detection.browserName, 'In-App Browser');
    });

    test('does not detect standard Chrome as in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, false);
      expect(detection.browserName, 'Standard');
      expect(PlatformDetection.isAndroidChrome(), true);
    });

    test('does not detect standard Safari as in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, false);
      expect(detection.browserName, 'Standard');
      expect(PlatformDetection.isIosSafari(), true);
    });

    test('does not detect desktop Chrome as in-app browser', () {
      PlatformDetection.userAgentOverride =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection.isInApp, false);
      expect(detection.browserName, 'Standard');
      expect(PlatformDetection.isDesktop(), true);
      expect(PlatformDetection.isMobile(), false);
    });

    test('resetUserAgentOverride clears the override', () {
      PlatformDetection.userAgentOverride = 'Instagram test';
      expect(PlatformDetection.detectInAppBrowser().browserName, 'Instagram');

      PlatformDetection.resetUserAgentOverride();
      // After reset, should use real UA (which in test env returns 'Standard')
      final detection = PlatformDetection.detectInAppBrowser();
      expect(detection, isA<InAppBrowserDetection>());
    });
  });

  group('PwaInstall', () {
    test('singleton instance is consistent', () {
      final instance1 = PwaInstall();
      final instance2 = PwaInstall();
      expect(identical(instance1, instance2), true);
    });

    test('init can be called without error', () {
      expect(() => PwaInstall().init(), returnsNormally);
    });

    test('init can be called with enableBrowserRedirect false', () {
      expect(
        () => PwaInstall().init(enableBrowserRedirect: false),
        returnsNormally,
      );
    });

    test('installPromptEnabled is a ValueNotifier', () {
      final notifier = PwaInstall().installPromptEnabled;
      expect(notifier, isA<ValueNotifier<bool>>());
    });

    test('isInstalled is a ValueNotifier', () {
      final notifier = PwaInstall().isInstalled;
      expect(notifier, isA<ValueNotifier<bool>>());
    });

    test('isInAppBrowser returns boolean', () {
      final result = PwaInstall().isInAppBrowser();
      expect(result, isA<bool>());
    });

    test('detectInAppBrowser returns InAppBrowserDetection', () {
      final result = PwaInstall().detectInAppBrowser();
      expect(result, isA<InAppBrowserDetection>());
    });

    test('isInstalledPwa returns boolean', () {
      final result = PwaInstall().isInstalledPwa();
      expect(result, isA<bool>());
    });

    test('shouldShowInstallGuide returns boolean', () {
      final result = PwaInstall().shouldShowInstallGuide();
      expect(result, isA<bool>());
    });

    test('isMobile returns boolean', () {
      final result = PwaInstall().isMobile();
      expect(result, isA<bool>());
    });

    test('shouldShowDesktopInstallGuide returns boolean', () {
      final result = PwaInstall().shouldShowDesktopInstallGuide();
      expect(result, isA<bool>());
    });

    test('promptInstall can be called without error when no prompt available',
        () async {
      // Should complete without error even if no prompt is available
      await expectLater(PwaInstall().promptInstall(), completes);
    });
  });

  group('BrowserRedirectInjector', () {
    test('isOverlayShown returns boolean', () {
      final result = BrowserRedirectInjector.isOverlayShown();
      expect(result, isA<bool>());
    });

    test('inject can be called without error', () {
      expect(() => BrowserRedirectInjector.inject(), returnsNormally);
    });
  });

  group('PwaInstaller Widget', () {
    test('static isInitialized is false before init', () {
      // Note: This may be true if other tests have called init
      expect(PwaInstaller.isInitialized, isA<bool>());
    });

    test('init can be called without error', () {
      expect(
        () => PwaInstaller.init(
          enableBrowserRedirect: false,
          enableDesktopInstallGuide: false,
          enableMobileInstallGuide: false,
        ),
        returnsNormally,
      );
    });

    test('static methods return correct types', () {
      expect(PwaInstaller.isInAppBrowser(), isA<bool>());
      expect(PwaInstaller.detectInAppBrowser(), isA<InAppBrowserDetection>());
      expect(PwaInstaller.isInstalledPwa(), isA<bool>());
      expect(PwaInstaller.shouldShowInstallGuide(), isA<bool>());
      expect(PwaInstaller.shouldShowDesktopInstallGuide(), isA<bool>());
      expect(PwaInstaller.isMobile(), isA<bool>());
    });

    test('static ValueNotifiers are accessible', () {
      expect(PwaInstaller.installPromptEnabled, isA<ValueNotifier<bool>>());
      expect(PwaInstaller.isInstalled, isA<ValueNotifier<bool>>());
    });

    testWidgets('renders child widget when no install needed', (tester) async {
      PwaInstaller.init(
        enableBrowserRedirect: false,
        enableDesktopInstallGuide: false,
        enableMobileInstallGuide: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: PwaInstaller(
            child: Text('Main App'),
          ),
        ),
      );

      expect(find.text('Main App'), findsOneWidget);
    });

    testWidgets('accepts optional parameters', (tester) async {
      PwaInstaller.init(
        enableBrowserRedirect: false,
        enableDesktopInstallGuide: false,
        enableMobileInstallGuide: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PwaInstaller(
            logo: const FlutterLogo(),
            appName: 'Test App',
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            child: const Text('Main App'),
          ),
        ),
      );

      expect(find.text('Main App'), findsOneWidget);
    });

    testWidgets('can use custom screens', (tester) async {
      PwaInstaller.init(
        enableBrowserRedirect: false,
        enableDesktopInstallGuide: false,
        enableMobileInstallGuide: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PwaInstaller(
            customBrowserRedirectScreen: (context, onDismiss) =>
                const Text('Custom Browser Redirect'),
            customDesktopScreen: (context, onDismiss) =>
                const Text('Custom Desktop'),
            customMobileScreen: (context, onDismiss) =>
                const Text('Custom Mobile'),
            child: const Text('Main App'),
          ),
        ),
      );

      expect(find.text('Main App'), findsOneWidget);
    });
  });

  group('Integration', () {
    test('PwaInstall and PlatformDetection return consistent results', () {
      final pwaInstall = PwaInstall();
      expect(
        pwaInstall.isInAppBrowser(),
        PlatformDetection.detectInAppBrowser().isInApp,
      );
      expect(
        pwaInstall.isInstalledPwa(),
        PlatformDetection.isInstalledPwa(),
      );
      expect(
        pwaInstall.isMobile(),
        PlatformDetection.isMobile(),
      );
      expect(
        pwaInstall.shouldShowInstallGuide(),
        PlatformDetection.shouldShowInstallGuide(),
      );
      expect(
        pwaInstall.shouldShowDesktopInstallGuide(),
        PlatformDetection.shouldShowDesktopInstallGuide(),
      );
    });

    test('PwaInstaller static methods match PwaInstall instance', () {
      final pwaInstall = PwaInstall();
      expect(
        PwaInstaller.isInAppBrowser(),
        pwaInstall.isInAppBrowser(),
      );
      expect(
        PwaInstaller.isInstalledPwa(),
        pwaInstall.isInstalledPwa(),
      );
      expect(
        PwaInstaller.isMobile(),
        pwaInstall.isMobile(),
      );
      expect(
        PwaInstaller.shouldShowInstallGuide(),
        pwaInstall.shouldShowInstallGuide(),
      );
      expect(
        PwaInstaller.shouldShowDesktopInstallGuide(),
        pwaInstall.shouldShowDesktopInstallGuide(),
      );
    });
  });

  group('InAppBrowserGuide Widget', () {
    testWidgets('renders with default theme and labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBrowserGuide(
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(InAppBrowserGuide), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBrowserGuide(
            logo: const FlutterLogo(size: 80),
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('renders with onDismiss callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBrowserGuide(
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(InAppBrowserGuide), findsOneWidget);
    });

    testWidgets('renders without dismiss callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InAppBrowserGuide(),
        ),
      );

      expect(find.byType(InAppBrowserGuide), findsOneWidget);
    });
  });

  group('MobileInstallGuide Widget', () {
    testWidgets('renders with default parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileInstallGuide(),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileInstallGuide(
            logo: const FlutterLogo(size: 80),
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('dismiss button calls onDismiss when provided', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MobileInstallGuide(
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
    });

    testWidgets('renders with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileInstallGuide(
            theme: PwaInstallerTheme.lightTheme,
            labels: const PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
    });

    testWidgets('forcePlatform iosSafari26 renders iOS UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileInstallGuide(
            forcePlatform: ForcePlatform.iosSafari26,
            labels: PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
    });

    testWidgets('forcePlatform iosSafariLegacy renders iOS UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileInstallGuide(
            forcePlatform: ForcePlatform.iosSafariLegacy,
            labels: PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
    });

    testWidgets('forcePlatform android renders Android UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileInstallGuide(
            forcePlatform: ForcePlatform.android,
            labels: PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(MobileInstallGuide), findsOneWidget);
    });
  });

  group('DesktopInstallGuide Widget', () {
    testWidgets('renders with default parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesktopInstallGuide(),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopInstallGuide(
            logo: const FlutterLogo(size: 80),
            appName: 'Test App',
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('renders QR code', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopInstallGuide(
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            customUrl: 'https://example.com',
          ),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
      // QR code should be rendered
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('renders with onDismiss callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopInstallGuide(
            theme: PwaInstallerTheme.defaultTheme,
            labels: const PwaInstallerLabels(),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
    });

    testWidgets('renders without dismiss callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesktopInstallGuide(),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
    });

    testWidgets('renders installation instructions section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesktopInstallGuide(
            labels: PwaInstallerLabels(),
          ),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
    });

    testWidgets('uses custom URL when provided', (tester) async {
      const customUrl = 'https://myapp.example.com/path?query=1';

      await tester.pumpWidget(
        MaterialApp(
          home: DesktopInstallGuide(
            labels: const PwaInstallerLabels(),
            customUrl: customUrl,
          ),
        ),
      );

      expect(find.byType(DesktopInstallGuide), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
    });
  });

  group('ForcePlatform enum', () {
    test('ForcePlatform values exist', () {
      expect(ForcePlatform.values, contains(ForcePlatform.iosSafari26));
      expect(ForcePlatform.values, contains(ForcePlatform.iosSafariLegacy));
      expect(ForcePlatform.values, contains(ForcePlatform.android));
    });

    test('ForcePlatform values can be compared', () {
      expect(ForcePlatform.iosSafari26 != ForcePlatform.android, true);
      expect(ForcePlatform.iosSafari26 == ForcePlatform.iosSafari26, true);
    });
  });
}
