/// Localizable labels for install guide screens.
///
/// All labels have English defaults but can be customized for localization.
class PwaInstallerLabels {
  /// Title for "Add" part (e.g., "Add ")
  final String titleAdd;

  /// Title for "to Home Screen" part
  final String titleToHomeScreen;

  /// Description text explaining why to install
  final String description;

  // iOS labels
  final String iosStep1;
  final String iosStep2;
  final String iosStep3;
  final String iosLegacyStep1;
  final String iosLegacyStep2;

  // Android labels
  final String androidStep1;
  final String androidStep2;

  // Common labels
  final String addToHomeScreen;
  final String installApp;
  final String share;
  final String openInBrowser;
  final String copyLink;
  final String linkCopied;

  // Fallback labels
  final String fallbackMessage;
  final String unsupportedBrowserMessage;

  // Desktop labels
  final String desktopTitle;
  final String desktopDescription;
  final String desktopHowToInstall;
  final String desktopIosTitle;
  final String desktopAndroidTitle;
  final String desktopIosStep1;
  final String desktopIosStep2;
  final String desktopIosStep3;
  final String desktopAndroidStep1;
  final String desktopAndroidStep2;
  final String desktopQrError;
  final String desktopDismissButton;

  const PwaInstallerLabels({
    this.titleAdd = 'Add ',
    this.titleToHomeScreen = 'to Home Screen',
    this.description =
        'To use this app, you need to add it to\nyour home screen.',
    this.iosStep1 = 'Tap the ... button in the bottom right corner of Safari',
    this.iosStep2 = 'Tap the Share button in the menu',
    this.iosStep3 = 'Select "Add to Home Screen" from the share menu',
    this.iosLegacyStep1 = 'Tap the share icon in Safari',
    this.iosLegacyStep2 = 'Select "Add to Home Screen" from the share menu',
    this.androidStep1 = 'Tap the menu icon in Chrome',
    this.androidStep2 = 'Select "Add to Home Screen" from the menu',
    this.addToHomeScreen = 'Add to Home Screen',
    this.installApp = 'Install App',
    this.share = 'Share',
    this.openInBrowser = 'Open in Browser',
    this.copyLink = 'Copy Link',
    this.linkCopied = 'Link Copied!',
    this.fallbackMessage =
        'This app works best when installed from Safari (iOS) or Chrome (Android)',
    this.unsupportedBrowserMessage =
        'Please open this site in Safari (iOS) or Chrome (Android)',
    this.desktopTitle = 'Install on your mobile device',
    this.desktopDescription =
        'Scan the QR code with your phone to install this app',
    this.desktopHowToInstall = 'How to Install',
    this.desktopIosTitle = 'iPhone / iPad',
    this.desktopAndroidTitle = 'Android',
    this.desktopIosStep1 = 'Open the link in Safari',
    this.desktopIosStep2 = 'Tap the Share button',
    this.desktopIosStep3 = 'Select "Add to Home Screen"',
    this.desktopAndroidStep1 = 'Open the link in Chrome',
    this.desktopAndroidStep2 = 'Tap "Add to Home Screen" in the menu',
    this.desktopQrError = 'Could not generate QR code',
    this.desktopDismissButton = 'Continue to website',
  });

  /// Creates a copy with specified labels replaced.
  PwaInstallerLabels copyWith({
    String? titleAdd,
    String? titleToHomeScreen,
    String? description,
    String? iosStep1,
    String? iosStep2,
    String? iosStep3,
    String? iosLegacyStep1,
    String? iosLegacyStep2,
    String? androidStep1,
    String? androidStep2,
    String? addToHomeScreen,
    String? installApp,
    String? share,
    String? openInBrowser,
    String? copyLink,
    String? linkCopied,
    String? fallbackMessage,
    String? unsupportedBrowserMessage,
    String? desktopTitle,
    String? desktopDescription,
    String? desktopHowToInstall,
    String? desktopIosTitle,
    String? desktopAndroidTitle,
    String? desktopIosStep1,
    String? desktopIosStep2,
    String? desktopIosStep3,
    String? desktopAndroidStep1,
    String? desktopAndroidStep2,
    String? desktopQrError,
    String? desktopDismissButton,
  }) {
    return PwaInstallerLabels(
      titleAdd: titleAdd ?? this.titleAdd,
      titleToHomeScreen: titleToHomeScreen ?? this.titleToHomeScreen,
      description: description ?? this.description,
      iosStep1: iosStep1 ?? this.iosStep1,
      iosStep2: iosStep2 ?? this.iosStep2,
      iosStep3: iosStep3 ?? this.iosStep3,
      iosLegacyStep1: iosLegacyStep1 ?? this.iosLegacyStep1,
      iosLegacyStep2: iosLegacyStep2 ?? this.iosLegacyStep2,
      androidStep1: androidStep1 ?? this.androidStep1,
      androidStep2: androidStep2 ?? this.androidStep2,
      addToHomeScreen: addToHomeScreen ?? this.addToHomeScreen,
      installApp: installApp ?? this.installApp,
      share: share ?? this.share,
      openInBrowser: openInBrowser ?? this.openInBrowser,
      copyLink: copyLink ?? this.copyLink,
      linkCopied: linkCopied ?? this.linkCopied,
      fallbackMessage: fallbackMessage ?? this.fallbackMessage,
      unsupportedBrowserMessage:
          unsupportedBrowserMessage ?? this.unsupportedBrowserMessage,
      desktopTitle: desktopTitle ?? this.desktopTitle,
      desktopDescription: desktopDescription ?? this.desktopDescription,
      desktopHowToInstall: desktopHowToInstall ?? this.desktopHowToInstall,
      desktopIosTitle: desktopIosTitle ?? this.desktopIosTitle,
      desktopAndroidTitle: desktopAndroidTitle ?? this.desktopAndroidTitle,
      desktopIosStep1: desktopIosStep1 ?? this.desktopIosStep1,
      desktopIosStep2: desktopIosStep2 ?? this.desktopIosStep2,
      desktopIosStep3: desktopIosStep3 ?? this.desktopIosStep3,
      desktopAndroidStep1: desktopAndroidStep1 ?? this.desktopAndroidStep1,
      desktopAndroidStep2: desktopAndroidStep2 ?? this.desktopAndroidStep2,
      desktopQrError: desktopQrError ?? this.desktopQrError,
      desktopDismissButton: desktopDismissButton ?? this.desktopDismissButton,
    );
  }
}
