
Here's what I recommend for screenshots:
Recommended Screenshots
| Priority | Screen | Why |
|----------|--------|-----|
| High | iOS Install Guide (Safari 26+ Liquid Glass) | Your key differentiator - shows modern iOS support |
| High | iOS Install Guide (Legacy Safari) | Shows you handle older iOS too |
| High | Android Install Guide | Covers the other major mobile platform |
| High | In-App Browser Redirect | Solves a major pain point - very visual |
| Medium | Desktop QR Code Screen | Shows the desktop-to-mobile flow |
| Medium | Example App Home | Shows the status card and preview buttons |
How to Capture
Use the example app's "Demo Screens" buttons to preview each screen from any browser, then take screenshots.
For best results:
- Use browser DevTools device emulation (iPhone 14 Pro, Pixel 7)
- Set viewport to ~390x844 (standard mobile size)
- Take both light and dark if applicable
Where to Store
# List repo root directory
$ ls -la /Users/fabapps/Documents/Dev/me/packages/pwa/
total 104
drwxr-xr-x@ 19 fabapps  staff    608 Jan 30 14:20 .
drwxr-xr-x@  8 fabapps  staff    256 Jan 22 20:23 ..
drwxr-xr-x@  3 fabapps  staff     96 Jan 30 14:20 .claude
drwxr-xr-x@  7 fabapps  staff    224 Dec 12 05:54 .dart_tool
-rw-r--r--@  1 fabapps  staff   1732 Jan 30 14:35 .flutter-plugins-dependencies
drwxr-xr-x@ 14 fabapps  staff    448 Jan 30 19:01 .git
-rw-r--r--@  1 fabapps  staff    786 Dec 12 06:30 .gitignore
drwxr-xr-x@  5 fabapps  staff    160 Dec 12 04:53 .idea
-rw-r--r--@  1 fabapps  staff    154 Dec 12 04:53 analysis_options.yaml
…
Click to expand
Recommended location: Create a screenshots/ folder in the repo root.
pwa/
├── screenshots/
│   ├── ios-safari26.png
│   ├── ios-legacy.png
│   ├── android.png
│   ├── in-app-browser.png
│   ├── desktop-qr.png
│   └── example-app.png
├── lib/
├── example/
└── README.md
README Format
For pub.dev, reference images with raw GitHub URLs:
 Screenshots
| iOS (Safari 26+) | iOS (Legacy) | Android |
|:---:|:---:|:---:|
| ![iOS Safari 26+](https://raw.githubusercontent.com/YOUR_USERNAME/pwa_installer/main/screenshots/ios-safari26.png) | ![iOS Legacy](https://raw.githubusercontent.com/YOUR_USERNAME/pwa_installer/main/screenshots/ios-legacy.png) | ![Android](https://raw.githubusercontent.com/YOUR_USERNAME/pwa_installer/main/screenshots/android.png) |
| In-App Browser | Desktop QR |
|:---:|:---:|
| ![In-App Browser](https://raw.githubusercontent.com/YOUR_USERNAME/pwa_installer/main/screenshots/in-app-browser.png) | ![Desktop](https://raw.githubusercontent.com/YOUR_USERNAME/pwa_installer/main/screenshots/desktop-qr.png) |