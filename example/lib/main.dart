import 'package:flutter/material.dart';
import 'package:pwa_installer/pwa_installer.dart';

void main() {
  // Initialize PWA Installer with enable flags
  PwaInstaller.init(
    enableBrowserRedirect: true,
    enableDesktopInstallGuide: true,
    enableMobileInstallGuide: true,
  );
  runApp(const MyApp());
}

/// Example using the unified PwaInstaller approach.
///
/// This automatically handles:
/// - In-app browser detection → InAppBrowserGuide
/// - Desktop browser → DesktopInstallGuide (QR code)
/// - Mobile browser → MobileInstallGuide
/// - Installed PWA → Your app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Install Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Wrap your home with PwaInstaller for automatic handling
      home: PwaInstaller(
        logo: const Icon(Icons.flutter_dash, size: 80, color: Colors.white),
        appName: 'PWA Demo',
        theme: PwaInstallerTheme.defaultTheme,
        child: const MyHomePage(),
      ),
    );
  }
}

/// Routes based on browser/platform detection
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. If running in an in-app browser, show force browser screen
    if (PwaInstaller.isInAppBrowser()) {
      return InAppBrowserGuide(
        logo:
            const Icon(Icons.flutter_dash, size: 80, color: Color(0xFF6750A4)),
        theme: PwaInstallerTheme.defaultTheme,
        onDismiss: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        ),
      );
    }

    // 2. If on desktop, show desktop install guide with QR code
    if (PwaInstaller.shouldShowDesktopInstallGuide()) {
      return DesktopInstallGuide(
        logo: const Icon(Icons.flutter_dash, size: 80, color: Colors.white),
        appName: 'PWA Demo',
        theme: PwaInstallerTheme.defaultTheme,
        onDismiss: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        ),
      );
    }

    // 3. If on mobile browser and not installed as PWA, show install guide
    if (PwaInstaller.shouldShowInstallGuide()) {
      return MobileInstallGuide(
        logo: const Icon(Icons.flutter_dash, size: 80, color: Colors.white),
        theme: PwaInstallerTheme.defaultTheme,
        labels: const PwaInstallerLabels(),
        onDismiss: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        ),
      );
    }

    // 4. Normal app experience (installed PWA)
    return const MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final detection = PwaInstaller.detectInAppBrowser();
    final isInstalled = PwaInstaller.isInstalledPwa();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PWA Install Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context, detection, isInstalled),
            const SizedBox(height: 16),
            _buildInstallCard(context),
            const SizedBox(height: 16),
            _buildDemoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, InAppBrowserDetection detection, bool isInstalled) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform Status',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatusRow(
                'In-App Browser',
                detection.isInApp ? detection.browserName : 'No',
                detection.isInApp ? Colors.orange : Colors.green),
            _buildStatusRow('Installed as PWA', isInstalled ? 'Yes' : 'No',
                isInstalled ? Colors.green : Colors.grey),
            _buildStatusRow('iOS Safari',
                PlatformDetection.isIosSafari() ? 'Yes' : 'No', null),
            _buildStatusRow('Safari 26+ (Liquid Glass)',
                PlatformDetection.isSafari26OrNewer() ? 'Yes' : 'No', null),
            _buildStatusRow('Android Chrome',
                PlatformDetection.isAndroidChrome() ? 'Yes' : 'No', null),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Install App',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: PwaInstaller.installPromptEnabled,
              builder: (context, enabled, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed:
                          enabled ? () => PwaInstaller.promptInstall() : null,
                      icon: const Icon(Icons.download),
                      label: Text(enabled
                          ? 'Install App'
                          : 'Install Prompt Not Available'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      enabled
                          ? 'Tap to install this app on your device.'
                          : 'The install prompt is only available on supported browsers (e.g., Android Chrome). On iOS, use "Share → Add to Home Screen".',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo Screens',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MobileInstallGuide(
                    logo: const Icon(Icons.flutter_dash,
                        size: 80, color: Colors.white),
                    onDismiss: () => Navigator.pop(context),
                    forcePlatform: ForcePlatform.iosSafari26,
                  ),
                ),
              ),
              child: const Text('Preview iOS Safari 26+ (Liquid Glass)'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MobileInstallGuide(
                    logo: const Icon(Icons.flutter_dash,
                        size: 80, color: Colors.white),
                    onDismiss: () => Navigator.pop(context),
                    forcePlatform: ForcePlatform.iosSafariLegacy,
                  ),
                ),
              ),
              child: const Text('Preview iOS Safari Legacy'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MobileInstallGuide(
                    logo: const Icon(Icons.flutter_dash,
                        size: 80, color: Colors.white),
                    onDismiss: () => Navigator.pop(context),
                    forcePlatform: ForcePlatform.android,
                  ),
                ),
              ),
              child: const Text('Preview Install Guide Android'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DesktopInstallGuide(
                    logo: const Icon(Icons.flutter_dash,
                        size: 80, color: Colors.white),
                    appName: 'PWA Demo',
                    onDismiss: () => Navigator.pop(context),
                  ),
                ),
              ),
              child: const Text('Preview Desktop Install Screen'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InAppBrowserGuide(
                    logo: const Icon(Icons.flutter_dash,
                        size: 80, color: Color(0xFF6750A4)),
                    onDismiss: () => Navigator.pop(context),
                  ),
                ),
              ),
              child: const Text('Preview Force Browser Screen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color? statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              if (statusColor != null) ...[
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
              ],
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
