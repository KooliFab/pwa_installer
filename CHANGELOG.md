# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-02-17

### Changed

- **Breaking Change**: `forceInstall` now defaults to `true` in `PwaInstaller`.
- Updated `shouldShowDesktopInstallGuide` to accept `forceInstall` parameter across `PlatformDetection`, `PwaInstall`, and `PwaInstaller`.
- Condensed package description in `pubspec.yaml`.
- Improved test coverage for `forceInstall` behavior and dismiss button interaction.

### Added

- Added `.pubignore` to exclude development files from package.

## [0.1.1] - 2026-02-09

### Fixed

- Fixed repository URLs in `pubspec.yaml`
- Fixed GitHub links in `README.md`
- Fixed image display on pub.dev by updating repository metadata

## [0.1.0] - 2024-12-24

### Changed

- Restructured package with cleaner file organization
- Renamed classes for better clarity:
  - `PwaInstallerService` → `PwaInstall`
  - `PwaPlatformDetection` → `PlatformDetection`
  - `PwaInAppBrowserGuide` → `InAppBrowserGuide`
  - `PwaInstallerGuideMobile` → `MobileInstallGuide`
  - `PwaInstallerGuideDesktop` → `DesktopInstallGuide`
- Removed debug toast from browser redirect script
- Bumped version to 0.1.0 to signal initial release readiness

### Fixed

- Fixed duplicate doc comments in theme file
- Fixed README package name references

## [0.0.1] - 2024-12-12

### Added

- Initial release of pwa_installer package
- `PwaInstall` singleton class for PWA installation management
- `PlatformDetection` service for browser and platform detection
- In-app browser detection for 10+ platforms
- `InAppBrowserGuide` widget to redirect users from in-app browsers
- `MobileInstallGuide` widget with step-by-step installation guides
- `DesktopInstallGuide` widget with QR code for mobile scanning
- iOS Safari support including Safari 26+ "Liquid Glass" design
- Android Chrome installation prompt support
- `PwaInstallerTheme` for customizable styling
- `PwaInstallerLabels` for i18n/localization support
