import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../core/install_service.dart';
import '../theme/theme.dart';
import '../theme/labels.dart';

/// Platform to force for demo/preview purposes.
enum ForcePlatform {
  /// iOS Safari 26+ with "Liquid Glass" floating address bar (iOS 18.6+)
  iosSafari26,

  /// iOS Safari legacy with bottom toolbar (iOS < 18.6)
  iosSafariLegacy,

  /// Android Chrome with bottom navigation bar
  android,
}

/// A screen that guides users to install the PWA on their mobile device.
///
/// Automatically detects the platform (iOS, Android) and shows
/// appropriate installation instructions with visual guides.
class MobileInstallGuide extends StatelessWidget {
  /// Custom theme for styling.
  final PwaInstallerTheme? theme;

  /// Custom labels for localization.
  final PwaInstallerLabels? labels;

  /// Optional logo widget to display at the top.
  final Widget? logo;

  /// Callback when the user dismisses the screen.
  final VoidCallback? onDismiss;

  /// Force a specific platform for demo/preview purposes.
  /// If null, the platform is auto-detected.
  final ForcePlatform? forcePlatform;

  const MobileInstallGuide({
    super.key,
    this.theme,
    this.labels,
    this.logo,
    this.onDismiss,
    this.forcePlatform,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? PwaInstallerTheme.defaultTheme;
    final effectiveLabels = labels ?? const PwaInstallerLabels();

    final isIOS = forcePlatform == ForcePlatform.iosSafari26 ||
        forcePlatform == ForcePlatform.iosSafariLegacy ||
        (forcePlatform == null && PlatformDetection.isIosSafari());
    final isAndroid = forcePlatform == ForcePlatform.android ||
        (forcePlatform == null && PlatformDetection.isAndroidChrome());
    final isSafari26OrNewer = forcePlatform == ForcePlatform.iosSafari26 ||
        (forcePlatform == null && PlatformDetection.isSafari26OrNewer());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: effectiveTheme.backgroundGradient,
          color: effectiveTheme.backgroundGradient == null
              ? effectiveTheme.backgroundColor
              : null,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: effectiveTheme.contentPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (logo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: effectiveTheme.textColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: logo,
                    ),
                    const SizedBox(height: 24),
                  ],
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: effectiveLabels.titleAdd,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: effectiveTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextSpan(
                          text: effectiveLabels.titleToHomeScreen,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: effectiveTheme.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    effectiveLabels.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: effectiveTheme.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (isIOS) ...[
                    if (isSafari26OrNewer)
                      ..._buildIosSafari26Steps(
                          context, effectiveTheme, effectiveLabels)
                    else
                      ..._buildIosLegacySteps(
                          context, effectiveTheme, effectiveLabels),
                  ] else if (isAndroid) ...[
                    ValueListenableBuilder<bool>(
                      valueListenable: PwaInstall().installPromptEnabled,
                      builder: (context, promptAvailable, _) {
                        if (promptAvailable) {
                          return _buildAndroidInstallButton(
                              context, effectiveTheme, effectiveLabels);
                        }
                        // Prompt not yet available (first visit / engagement
                        // heuristic not met). Fall back to static step guide.
                        return Column(
                          children: _buildAndroidSteps(
                              context, effectiveTheme, effectiveLabels),
                        );
                      },
                    ),
                  ] else ...[
                    _buildFallbackMessage(
                        context, effectiveTheme, effectiveLabels),
                  ],
                  if (onDismiss != null) ...[
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: onDismiss,
                      child: Text('Continue without installing',
                          style: TextStyle(
                              color: effectiveTheme.secondaryTextColor)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIosSafari26Steps(BuildContext context,
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return [
      _buildInstallStep(
          context, theme, labels.iosStep1, _buildSafariAddressBarIos26(theme)),
      const SizedBox(height: 40),
      _buildInstallStep(context, theme, labels.iosStep2,
          _buildMoreMenuWithShare(theme, labels)),
      const SizedBox(height: 40),
      _buildInstallStep(context, theme, labels.iosStep3,
          _buildAddToHomeScreenButton(theme, labels)),
    ];
  }

  List<Widget> _buildIosLegacySteps(BuildContext context,
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return [
      _buildInstallStep(context, theme, labels.iosLegacyStep1,
          _buildSafariAddressBarLegacy(theme)),
      const SizedBox(height: 40),
      _buildInstallStep(context, theme, labels.iosLegacyStep2,
          _buildAddToHomeScreenButton(theme, labels)),
    ];
  }

  List<Widget> _buildAndroidSteps(BuildContext context, PwaInstallerTheme theme,
      PwaInstallerLabels labels) {
    return [
      _buildInstallStep(
          context, theme, labels.androidStep1, _buildChromeMenuBar(theme)),
      const SizedBox(height: 40),
      _buildInstallStep(context, theme, labels.androidStep2,
          _buildInstallAppButton(theme, labels)),
    ];
  }

  /// Real install button for Android Chrome when `beforeinstallprompt` is
  /// available. Tapping it calls [PwaInstall.promptInstall] which triggers
  /// Chrome's native install dialog.
  Widget _buildAndroidInstallButton(BuildContext context,
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => PwaInstall().promptInstall(),
        icon: const Icon(Icons.install_desktop,
            color: Colors.white, size: 24),
        label: Text(
          labels.installApp,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallStep(BuildContext context, PwaInstallerTheme theme,
      String description, Widget visual) {
    return Column(
      children: [
        visual,
        const SizedBox(height: 16),
        Text(description,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: theme.textColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ==========================================================================
  // SAFARI 26+ (iOS 18.6+) - Floating "Liquid Glass" Address Bar
  // ==========================================================================
  // Apple introduced a new floating address bar design in Safari 26 (iOS 18.6+)
  // called "Liquid Glass". The address bar floats at the bottom with a pill
  // shape, and the "..." (ellipsis) button opens the share menu.
  //
  // Visual: [< back] [🔒 example.com] [...] (floating pill)
  // ==========================================================================

  Widget _buildSafariAddressBarIos26(PwaInstallerTheme theme) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.darkSurfaceColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: theme.secondaryTextColor.withValues(alpha: 0.2),
                      width: 1),
                ),
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(CupertinoIcons.chevron_back,
                            color: theme.secondaryTextColor, size: 20)),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: theme.textColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock,
                                color: theme.secondaryTextColor, size: 14),
                            const SizedBox(width: 6),
                            Flexible(
                                child: Text(
                                    kIsWeb
                                        ? web.window.location.host
                                        : 'example.com',
                                    style: TextStyle(
                                        color: theme.secondaryTextColor,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle),
                      child: Icon(CupertinoIcons.ellipsis,
                          color: theme.accentColor, size: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SAFARI LEGACY (iOS < 18.6) - Bottom Toolbar with Share Button
  // ==========================================================================
  // Older Safari versions show a bottom toolbar with navigation buttons.
  // The share button (square with arrow) is in the center of the toolbar.
  //
  // Visual: [< back] [forward >] [⬆ share] [📖 book] [⧉ tabs]
  // ==========================================================================

  Widget _buildSafariAddressBarLegacy(PwaInstallerTheme theme) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.lock,
                  color: theme.secondaryTextColor, size: 16),
              const SizedBox(width: 8),
              Text(kIsWeb ? web.window.location.host : 'example.com',
                  style: TextStyle(color: theme.secondaryTextColor)),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.arrow_clockwise,
                  color: theme.secondaryTextColor, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(CupertinoIcons.chevron_back,
                  color: theme.secondaryTextColor),
              Icon(CupertinoIcons.chevron_forward,
                  color: theme.secondaryTextColor),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle),
                child: Icon(CupertinoIcons.share,
                    color: theme.accentColor, size: 28),
              ),
              Icon(CupertinoIcons.book, color: theme.secondaryTextColor),
              Icon(CupertinoIcons.square_on_square,
                  color: theme.secondaryTextColor),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SAFARI SHARE MENU (iOS) - "More" Menu with Share Option
  // ==========================================================================
  // When tapping the ellipsis (...) in Safari 26+ or the share button in
  // legacy Safari, this menu appears. The "Share" option is highlighted
  // to guide the user.
  //
  // Visual: [⬆ Share] (highlighted) | [🔖 Add Bookmark] | [🔗 Copy Link]
  // ==========================================================================

  Widget _buildMoreMenuWithShare(
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16))),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle),
                child: Icon(CupertinoIcons.share,
                    color: theme.accentColor, size: 20),
              ),
              title: Text(labels.share,
                  style: TextStyle(
                      color: theme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Divider(height: 1, color: theme.secondaryTextColor),
          ListTile(
              leading: Icon(CupertinoIcons.bookmark,
                  color: theme.secondaryTextColor, size: 20),
              title: Text('Add Bookmark',
                  style: TextStyle(
                      color: theme.secondaryTextColor, fontSize: 16))),
          Divider(height: 1, color: theme.secondaryTextColor),
          ListTile(
              leading: Icon(CupertinoIcons.link,
                  color: theme.secondaryTextColor, size: 20),
              title: Text('Copy Link',
                  style: TextStyle(
                      color: theme.secondaryTextColor, fontSize: 16))),
        ],
      ),
    );
  }

  // ==========================================================================
  // iOS ACTION BUTTON - "Add to Home Screen"
  // ==========================================================================
  // After tapping Share, the user sees a list of actions. This mockup shows
  // the "Add to Home Screen" option with the plus-in-square icon.
  //
  // Visual: [Add to Home Screen                    ⊕]
  // ==========================================================================

  Widget _buildAddToHomeScreenButton(
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(labels.addToHomeScreen,
                  style: TextStyle(color: theme.textColor, fontSize: 16))),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(CupertinoIcons.add_circled, color: theme.accentColor),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ANDROID CHROME - Bottom Navigation Bar with Menu Button
  // ==========================================================================
  // Chrome on Android shows a bottom navigation bar. The three-dot menu (⋮)
  // on the right side opens the browser menu where "Install app" appears.
  //
  // Visual: [← back] [🏠 home] [⧉ tabs] [⋮ menu] (highlighted)
  // ==========================================================================

  Widget _buildChromeMenuBar(PwaInstallerTheme theme) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  color: theme.secondaryTextColor, size: 16),
              const SizedBox(width: 8),
              Text(kIsWeb ? web.window.location.host : 'example.com',
                  style: TextStyle(color: theme.secondaryTextColor)),
              const SizedBox(width: 8),
              Icon(Icons.refresh, color: theme.secondaryTextColor, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.arrow_back, color: theme.secondaryTextColor),
              Icon(Icons.home, color: theme.secondaryTextColor),
              Icon(Icons.tab, color: theme.secondaryTextColor),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle),
                child:
                    Icon(Icons.more_vert, color: theme.accentColor, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ANDROID ACTION BUTTON - "Install App"
  // ==========================================================================
  // After tapping the Chrome menu, the user sees "Install app" option.
  // This mockup shows the install option with download icon.
  //
  // Visual: [Install app                           ⬇]
  // ==========================================================================

  Widget _buildInstallAppButton(
      PwaInstallerTheme theme, PwaInstallerLabels labels) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(labels.addToHomeScreen,
                  style: TextStyle(color: theme.textColor, fontSize: 16))),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.install_desktop, color: theme.accentColor),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FALLBACK MESSAGE
  // ==========================================================================
  // Shown when the browser/platform is not recognized as iOS Safari or
  // Android Chrome. Displays a generic message to the user.
  // ==========================================================================

  Widget _buildFallbackMessage(BuildContext context, PwaInstallerTheme theme,
      PwaInstallerLabels labels) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
          color: theme.darkSurfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(labels.fallbackMessage,
                  style: TextStyle(color: theme.textColor, fontSize: 16),
                  textAlign: TextAlign.center))),
    );
  }
}
