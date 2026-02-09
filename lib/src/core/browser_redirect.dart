import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Injects a JavaScript-based in-app browser detection and redirect overlay.
///
/// This class provides a static method to inject a script that:
/// - Detects in-app browsers (Instagram, Facebook, TikTok, etc.)
/// - Shows an overlay with instructions to open in the default browser
/// - Provides auto-redirect buttons for iOS Safari and Android Chrome
///
/// The script executes immediately when injected, BEFORE Flutter fully loads.
class BrowserRedirectInjector {
  static bool _injected = false;

  /// Injects the browser redirect script into the page.
  ///
  /// This method is idempotent - calling it multiple times has no effect
  /// after the first call.
  ///
  /// [nonce] - Optional CSP nonce for apps using strict Content Security Policy.
  /// If your app has a CSP header with `script-src` that doesn't include
  /// `'unsafe-inline'`, pass the nonce value here to allow the script to execute.
  static void inject({String? nonce}) {
    if (!kIsWeb || _injected) return;

    try {
      final script =
          web.document.createElement('script') as web.HTMLScriptElement;
      script.text = _getRedirectScript();
      if (nonce != null) {
        script.setAttribute('nonce', nonce);
      }
      web.document.head?.appendChild(script);
      _injected = true;
      debugPrint('BrowserRedirectInjector: Script injected');
    } catch (e) {
      debugPrint('BrowserRedirectInjector: Failed to inject script: $e');
    }
  }

  /// Checks if the redirect overlay is currently shown.
  static bool isOverlayShown() {
    if (!kIsWeb) return false;

    try {
      final overlay =
          web.document.getElementById('pwa-browser-redirect-overlay');
      return overlay != null;
    } catch (e) {
      return false;
    }
  }

  /// Removes the redirect overlay from the DOM if it exists.
  static void removeOverlay() {
    if (!kIsWeb) return;

    try {
      final overlay =
          web.document.getElementById('pwa-browser-redirect-overlay');
      overlay?.remove();
    } catch (e) {
      debugPrint('BrowserRedirectInjector: Failed to remove overlay: $e');
    }
  }

  static String _getRedirectScript() {
    const accentColor = '#FF7A5A';
    const backgroundColor = '#1A1D32';
    const surfaceColor = '#1E1E1E';
    const textColor = '#FFFFFF';
    const title = 'Open in Browser';
    const message =
        'For the best experience and to enable all features, please open this link in your default browser.';

    // The JavaScript below is organized into sections:
    // 1. PWA Detection - Skip if already running as installed PWA
    // 2. In-App Browser Detection - Identify Instagram, Facebook, TikTok, etc.
    // 3. Overlay UI Generation - Create the redirect instruction overlay
    // 4. Redirect Logic - Attempt to open in native browser with error handling
    // 5. Clipboard Handling - Copy link functionality with fallback
    // 6. Initialization - Detect and show overlay if in-app browser
    return '''
(function() {
  'use strict';
  
  // ============================================================
  // SECTION 1: PWA Detection
  // Skip the entire script if already running as an installed PWA
  // ============================================================
  if (window.matchMedia('(display-mode: standalone)').matches ||
      window.matchMedia('(display-mode: fullscreen)').matches ||
      window.navigator.standalone === true) {
    return;
  }

  // ============================================================
  // SECTION 2: In-App Browser Detection
  // Checks user agent for known in-app browser signatures
  // Returns: { isInApp: boolean, browser: string }
  // ============================================================
  function detectInAppBrowser() {
    var ua = (navigator.userAgent || navigator.vendor || window.opera || '').toLowerCase();
    
    // Social media apps - each has unique UA tokens
    if (ua.indexOf('instagram') > -1) return { isInApp: true, browser: 'Instagram' };
    if (ua.indexOf('fban') > -1 || ua.indexOf('fbav') > -1 || ua.indexOf('messenger') > -1) return { isInApp: true, browser: 'Facebook' };
    if (ua.indexOf('linkedinapp') > -1) return { isInApp: true, browser: 'LinkedIn' };
    if (ua.indexOf('twitter') > -1) return { isInApp: true, browser: 'Twitter' };
    if (ua.indexOf('musical_ly') > -1 || ua.indexOf('tiktok') > -1 || ua.indexOf('bytedance') > -1) return { isInApp: true, browser: 'TikTok' };
    if (ua.indexOf('snapchat') > -1) return { isInApp: true, browser: 'Snapchat' };
    if (ua.indexOf('whatsapp') > -1) return { isInApp: true, browser: 'WhatsApp' };
    if (ua.indexOf('line/') > -1) return { isInApp: true, browser: 'Line' };
    if (ua.indexOf('micromessenger') > -1) return { isInApp: true, browser: 'WeChat' };
    if (ua.indexOf('slack') > -1) return { isInApp: true, browser: 'Slack' };
    if (ua.indexOf('discord') > -1) return { isInApp: true, browser: 'Discord' };
    
    // Generic Android WebView detection ("; wv)" token in UA)
    var isAndroid = ua.indexOf('android') > -1;
    var hasWebViewToken = ua.indexOf('; wv)') > -1 || ua.indexOf(';wv)') > -1;
    if (isAndroid && hasWebViewToken) return { isInApp: true, browser: 'In-App Browser' };
    
    return { isInApp: false, browser: 'Standard' };
  }

  // ============================================================
  // SECTION 3: Overlay UI Generation
  // Creates the visual overlay with instructions for opening in browser
  // Instructions are customized based on detected browser and platform
  // ============================================================
  function showOverlay(browserName) {
    if (document.getElementById('pwa-browser-redirect-overlay')) return;

    var isIOS = /ipad|iphone|ipod/.test(navigator.userAgent.toLowerCase());
    var step1Text, step2Text;
    
    // Customize instructions based on the detected in-app browser
    if (browserName === 'Instagram') {
      step1Text = isIOS ? 'Tap the three dots (•••) in the top right corner' : 'Tap the three dots (⋮) in the top right corner';
      step2Text = isIOS ? 'Select "Open in Safari"' : 'Select "Open in Chrome"';
    } else if (browserName === 'Facebook') {
      step1Text = isIOS ? 'Tap the three dots (•••) in the bottom right corner' : 'Tap the three dots (⋮) in the top right corner';
      step2Text = isIOS ? 'Select "Open in Safari"' : 'Select "Open in external browser"';
    } else if (browserName === 'TikTok') {
      step1Text = 'Tap the three dots (•••) or share button';
      step2Text = isIOS ? 'Select "Open in Safari"' : 'Select "Open in browser"';
    } else if (browserName === 'Discord') {
      step1Text = 'Tap the three dots (•••) or share';
      step2Text = 'Select "Open in Browser"';
    } else {
      step1Text = 'Look for a menu icon (⋮ or •••) in the app';
      step2Text = isIOS ? 'Select "Open in Safari"' : 'Select "Open in Chrome"';
    }

    var overlay = document.createElement('div');
    overlay.id = 'pwa-browser-redirect-overlay';
    overlay.innerHTML = [
      '<style>',
      '#pwa-browser-redirect-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: $backgroundColor; z-index: 999999; display: flex; align-items: center; justify-content: center; padding: 24px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; animation: pwaFadeIn 0.3s ease-out; }',
      '@keyframes pwaFadeIn { from { opacity: 0; } to { opacity: 1; } }',
      '.pwa-redirect-content { background: $surfaceColor; border-radius: 16px; padding: 32px 24px; max-width: 400px; width: 100%; text-align: center; }',
      '.pwa-redirect-icon { width: 80px; height: 80px; margin: 0 auto 24px; background: rgba(255,255,255,0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 40px; }',
      '.pwa-redirect-title { font-size: 24px; font-weight: 700; margin-bottom: 16px; color: $textColor; }',
      '.pwa-redirect-title span { color: $accentColor; }',
      '.pwa-redirect-message { font-size: 16px; color: $textColor; line-height: 1.6; margin-bottom: 32px; opacity: 0.9; }',
      '.pwa-redirect-step { display: flex; align-items: center; justify-content: space-between; padding: 16px; background: rgba(255,255,255,0.05); border-radius: 12px; margin-bottom: 12px; color: $textColor; font-size: 14px; text-align: left; }',
      '.pwa-step-icon { width: 40px; height: 40px; background: ' + '$accentColor' + '33; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: $accentColor; font-size: 20px; flex-shrink: 0; margin-left: 12px; }',
      '.pwa-redirect-button { background: ' + '$accentColor' + '33; color: $accentColor; border: none; border-radius: 12px; padding: 16px 24px; font-size: 16px; font-weight: 600; cursor: pointer; width: 100%; margin-top: 8px; display: flex; align-items: center; justify-content: center; gap: 8px; transition: opacity 0.2s; }',
      '.pwa-redirect-button:disabled { opacity: 0.6; cursor: not-allowed; }',
      '.pwa-redirect-button.pwa-redirect-failed { background: rgba(255,100,100,0.2); color: #ff6b6b; }',
      '.pwa-copy-button { background: transparent; color: rgba(255,255,255,0.7); border: 1px solid rgba(255,255,255,0.2); border-radius: 12px; padding: 14px 24px; font-size: 14px; cursor: pointer; width: 100%; margin-top: 12px; }',
      '</style>',
      '<div class="pwa-redirect-content">',
      '  <div class="pwa-redirect-icon">🌐</div>',
      '  <div class="pwa-redirect-title"><span>' + '$title' + '</span></div>',
      '  <div class="pwa-redirect-message">$message</div>',
      '  <div class="pwa-redirect-step"><div>' + step1Text + '</div><div class="pwa-step-icon">⋯</div></div>',
      '  <div class="pwa-redirect-step"><div>' + step2Text + '</div><div class="pwa-step-icon">' + (isIOS ? '🧭' : '🌐') + '</div></div>',
      '  <button class="pwa-redirect-button" id="pwa-redirect-btn" onclick="pwaAttemptRedirect()">' + (isIOS ? '🧭 Open in Safari' : '🌐 Open in Chrome') + '</button>',
      '  <button class="pwa-copy-button" onclick="pwaCopyLink()">📋 Copy Link</button>',
      '</div>'
    ].join('\\n');

    document.body.appendChild(overlay);
  }

  // ============================================================
  // SECTION 4: Redirect Logic
  // Attempts to open the current URL in the native browser.
  // Uses intent:// URLs on Android and x-safari-https:// on iOS.
  // Includes timeout-based error detection to show fallback UI.
  // ============================================================
  
  // Track redirect state to detect failures
  var redirectAttempted = false;
  var redirectTimeout = null;
  
  // Shows fallback UI when redirect fails (page still visible after timeout)
  function showRedirectFailed() {
    var btn = document.getElementById('pwa-redirect-btn');
    if (btn && !btn.classList.contains('pwa-redirect-failed')) {
      btn.classList.add('pwa-redirect-failed');
      btn.innerHTML = '⚠️ Auto-open failed - use steps above';
      btn.disabled = true;
      console.log('PWA: Redirect failed, showing fallback UI');
    }
  }

  window.pwaAttemptRedirect = function() {
    var btn = document.getElementById('pwa-redirect-btn');
    var host = window.location.host;
    var path = window.location.pathname + window.location.search + window.location.hash;
    var isIOS = /ipad|iphone|ipod/.test(navigator.userAgent.toLowerCase());
    var isAndroid = /android/.test(navigator.userAgent.toLowerCase());

    // Prevent multiple rapid attempts
    if (redirectAttempted) {
      console.log('PWA: Redirect already attempted');
      return;
    }
    redirectAttempted = true;
    
    // Update button to show attempting state
    if (btn) {
      btn.innerHTML = '⏳ Opening browser...';
      btn.disabled = true;
    }

    // Set timeout to detect if redirect failed (page still visible)
    // If redirect succeeds, this page will be hidden/unloaded
    redirectTimeout = setTimeout(function() {
      // Check if document is still visible (redirect likely failed)
      if (!document.hidden) {
        showRedirectFailed();
      }
    }, 2500);
    
    // Listen for visibility change - if page becomes hidden, redirect worked
    document.addEventListener('visibilitychange', function onVisChange() {
      if (document.hidden && redirectTimeout) {
        clearTimeout(redirectTimeout);
        redirectTimeout = null;
        document.removeEventListener('visibilitychange', onVisChange);
      }
    });

    try {
      if (isAndroid) {
        // Android: Try Chrome-specific intent first, then generic intent
        var chromeIntent = 'intent://' + host + path + '#Intent;scheme=https;package=com.android.chrome;end';
        window.location.href = chromeIntent;
        
        // Fallback to generic browser intent after 1 second
        setTimeout(function() {
          if (!document.hidden) {
            var genericIntent = 'intent://' + host + path + '#Intent;scheme=https;action=android.intent.action.VIEW;end';
            window.location.href = genericIntent;
          }
        }, 1000);
      } else if (isIOS) {
        // iOS: Try x-safari-https scheme, fallback to window.open
        var currentUrl = window.location.href;
        var safariUrl = currentUrl.replace(/^https?:\\/\\//, 'x-safari-https://');
        window.location.href = safariUrl;
        
        // Fallback: try opening in new tab after 500ms
        setTimeout(function() {
          if (!document.hidden) {
            window.open(currentUrl, '_blank');
          }
        }, 500);
      } else {
        // Unknown platform - show failure immediately
        showRedirectFailed();
      }
    } catch (e) {
      console.error('PWA: Redirect error:', e);
      showRedirectFailed();
    }
  };

  // ============================================================
  // SECTION 5: Clipboard Handling
  // Copies the current URL to clipboard with modern API fallback
  // Shows visual feedback on success/failure
  // ============================================================
  window.pwaCopyLink = function() {
    var currentUrl = window.location.href;
    var btn = document.querySelector('.pwa-copy-button');
    
    // Success handler - update button text
    function onCopySuccess() {
      if (btn) {
        btn.textContent = '✓ Link Copied!';
        setTimeout(function() { btn.innerHTML = '📋 Copy Link'; }, 2000);
      }
    }
    
    // Failure handler - show error state
    function onCopyFailed() {
      if (btn) {
        btn.textContent = '✗ Copy failed';
        btn.style.color = '#ff6b6b';
        setTimeout(function() { 
          btn.innerHTML = '📋 Copy Link'; 
          btn.style.color = '';
        }, 2000);
      }
      console.error('PWA: Clipboard copy failed');
    }
    
    // Try modern Clipboard API first
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(currentUrl)
        .then(onCopySuccess)
        .catch(onCopyFailed);
    } else {
      // Fallback: create temporary textarea for execCommand
      var textArea = document.createElement('textarea');
      textArea.value = currentUrl;
      textArea.style.position = 'fixed';
      textArea.style.left = '-9999px';
      document.body.appendChild(textArea);
      textArea.select();
      try {
        var success = document.execCommand('copy');
        if (success) {
          onCopySuccess();
        } else {
          onCopyFailed();
        }
      } catch (e) {
        onCopyFailed();
      }
      document.body.removeChild(textArea);
    }
  };

  // ============================================================
  // SECTION 6: Initialization
  // Runs detection and shows overlay if in-app browser detected
  // Auto-attempts redirect on detection
  // ============================================================
  var detection = detectInAppBrowser();
  if (detection.isInApp) {
    console.log('PWA: Detected in-app browser: ' + detection.browser);
    // Show overlay first, then attempt redirect
    showOverlay(detection.browser);
    // Small delay to ensure overlay is visible before redirect attempt
    setTimeout(function() {
      try { 
        if (window.pwaAttemptRedirect) window.pwaAttemptRedirect(); 
      } catch (e) { 
        console.error('PWA: Auto-redirect failed', e); 
      }
    }, 100);
  }
})();
''';
  }
}
