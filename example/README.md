# PWA Installer Example

This example demonstrates how to use the `pwa_installer` package to:

- Detect in-app browsers and redirect users to system browsers
- Show platform-specific PWA installation guides
- Trigger custom PWA install prompts on supported browsers

## Running the Example

```bash
cd example
flutter pub get
flutter run -d chrome
```

## Testing on Mobile

For the best experience, deploy to a web server and test on actual mobile devices:

```bash
flutter build web
# Deploy the build/web folder to your server
```

Then open the URL on:
- **iOS Safari** - to see the install guide with share button instructions
- **Android Chrome** - to see the native install prompt
- **Instagram/Facebook/etc.** - to see the force browser redirect screen
