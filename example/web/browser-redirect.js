/**
 * Browser Redirect Script for PWA Mobile Install
 * 
 * Detects in-app browsers (Instagram, Facebook, LinkedIn, etc.) and shows
 * an overlay with instructions to open in the default browser.
 * 
 * USAGE:
 * 1. Copy this file and browser-redirect-config.js to your web/ directory
 * 2. Add to your index.html <head> section:
 *    <script src="browser-redirect-config.js"></script>
 *    <script src="browser-redirect.js"></script>
 */

(function() {
  'use strict';

  /**
   * Detects if the current browser is an in-app browser
   * @returns {Object} Detection result with browser name and whether it's in-app
   */
  function detectInAppBrowser() {
    const ua = navigator.userAgent || navigator.vendor || window.opera;
    
    // Instagram in-app browser
    if (ua.indexOf('Instagram') > -1) {
      return { isInApp: true, browser: 'Instagram' };
    }
    
    // Facebook/Messenger in-app browser (FBAN = Facebook App, FBAV = Facebook App Version)
    if (ua.indexOf('FBAN') > -1 || ua.indexOf('FBAV') > -1) {
      return { isInApp: true, browser: 'Facebook' };
    }
    
    // LinkedIn in-app browser
    if (ua.indexOf('LinkedInApp') > -1) {
      return { isInApp: true, browser: 'LinkedIn' };
    }
    
    // Twitter in-app browser
    if (ua.indexOf('Twitter') > -1) {
      return { isInApp: true, browser: 'Twitter' };
    }
    
    // TikTok in-app browser
    if (ua.indexOf('musical_ly') > -1 || ua.indexOf('TikTok') > -1) {
      return { isInApp: true, browser: 'TikTok' };
    }
    
    // Snapchat in-app browser
    if (ua.indexOf('Snapchat') > -1) {
      return { isInApp: true, browser: 'Snapchat' };
    }
    
    // WhatsApp in-app browser
    if (ua.indexOf('WhatsApp') > -1) {
      return { isInApp: true, browser: 'WhatsApp' };
    }
    
    // Line in-app browser
    if (ua.indexOf('Line') > -1) {
      return { isInApp: true, browser: 'Line' };
    }
    
    // WeChat in-app browser
    if (ua.indexOf('MicroMessenger') > -1) {
      return { isInApp: true, browser: 'WeChat' };
    }
    
    return { isInApp: false, browser: 'Standard' };
  }

  /**
   * Shows an overlay with instructions to open in default browser
   * @param {string} browserName Name of the detected in-app browser
   */
  function showBrowserRedirectOverlay(browserName) {
    // Check if overlay already exists
    if (document.getElementById('browser-redirect-overlay')) {
      return;
    }

    const config = window.BROWSER_REDIRECT_CONFIG || {};
    const colors = config.colors || {};
    const messages = config.messages || {};

    const primaryColor = colors.primary || '#1A1D32';
    const accentColor = colors.accent || '#FF7A5A';
    const surfaceColor = colors.surface || '#1E1E1E';
    const textColor = colors.text || '#FFFFFF';

    const overlay = document.createElement('div');
    overlay.id = 'browser-redirect-overlay';
    overlay.innerHTML = `
      <style>
        #browser-redirect-overlay {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: linear-gradient(135deg, ${primaryColor} 0%, #725D78 100%);
          z-index: 999999;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 24px;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          animation: fadeIn 0.3s ease-out;
        }
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        .redirect-content {
          background: ${surfaceColor};
          border-radius: 16px;
          padding: 32px 24px;
          max-width: 400px;
          width: 100%;
          text-align: center;
          animation: slideUp 0.4s ease-out;
        }
        
        @keyframes slideUp {
          from {
            transform: translateY(30px);
            opacity: 0;
          }
          to {
            transform: translateY(0);
            opacity: 1;
          }
        }
        
        .redirect-icon {
          width: 80px;
          height: 80px;
          margin: 0 auto 24px;
          padding: 20px;
          background: rgba(255, 255, 255, 0.1);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 40px;
        }
        
        .redirect-title {
          font-size: 24px;
          font-weight: 700;
          margin-bottom: 16px;
        }
        
        .redirect-title-accent { color: ${accentColor}; }
        .redirect-title-main { color: ${textColor}; }
        
        .redirect-message {
          font-size: 16px;
          color: ${textColor};
          line-height: 1.6;
          margin-bottom: 32px;
        }
        
        .redirect-steps {
          background: rgba(255, 255, 255, 0.05);
          border-radius: 12px;
          margin-bottom: 24px;
          text-align: left;
        }
        
        .redirect-step {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px;
          font-size: 14px;
          color: ${textColor};
          border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .redirect-step:last-child {
          border-bottom: none;
        }
        
        .step-icon {
          width: 36px;
          height: 36px;
          background: rgba(${hexToRgb(accentColor)}, 0.3);
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
          margin-left: 12px;
          color: ${accentColor};
          font-size: 18px;
        }
        
        .redirect-button {
          background: rgba(${hexToRgb(accentColor)}, 0.3);
          color: ${accentColor};
          border: none;
          border-radius: 12px;
          padding: 16px 28px;
          font-size: 16px;
          font-weight: 600;
          cursor: pointer;
          width: 100%;
          transition: all 0.3s ease;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
        }
        
        .redirect-button:hover {
          background: rgba(${hexToRgb(accentColor)}, 0.4);
          transform: translateY(-2px);
        }
        
        .redirect-button:active {
          transform: translateY(0);
        }
        
        .redirect-dismiss {
          background: transparent;
          color: rgba(255, 255, 255, 0.6);
          border: none;
          padding: 12px;
          font-size: 14px;
          cursor: pointer;
          margin-top: 12px;
        }
      </style>
      
      <div class="redirect-content">
        <div class="redirect-icon">🌐</div>
        <div class="redirect-title">
          <span class="redirect-title-accent">${messages.titleAccent || 'Open in'}</span>
          <span class="redirect-title-main">${messages.titleMain || ' Browser'}</span>
        </div>
        <div class="redirect-message">
          ${messages.message || 'For the best experience and to enable all features, please open this link in your default browser.'}
        </div>
        
        <div class="redirect-steps">
          ${getInstructionsForBrowser(browserName)}
        </div>
        
        <button class="redirect-button" onclick="attemptBrowserRedirect()">
          <span>${isIOS() ? '🧭' : '🌐'}</span>
          <span>${isIOS() ? 'Open in Safari' : 'Open in Chrome'}</span>
        </button>
        
        ${config.allowDismiss !== false ? '<button class="redirect-dismiss" onclick="dismissRedirectOverlay()">Continue anyway</button>' : ''}
      </div>
    `;
    
    document.body.appendChild(overlay);
  }

  /**
   * Helper to convert hex color to RGB
   */
  function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? 
      `${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}` : 
      '255, 122, 90';
  }

  /**
   * Detect iOS device
   */
  function isIOS() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent);
  }

  /**
   * Gets platform-specific instructions for opening in default browser
   * @param {string} browserName Name of the detected in-app browser
   * @returns {string} HTML string with instructions
   */
  function getInstructionsForBrowser(browserName) {
    const iOS = isIOS();
    const isAndroid = /Android/.test(navigator.userAgent);
    
    let instructions = '';
    
    if (browserName === 'Instagram') {
      if (iOS) {
        instructions = `
          <div class="redirect-step">
            <div>Tap the three dots (•••) in the top right corner</div>
            <div class="step-icon">⋯</div>
          </div>
          <div class="redirect-step">
            <div>Select "Open in Safari"</div>
            <div class="step-icon">🧭</div>
          </div>
        `;
      } else if (isAndroid) {
        instructions = `
          <div class="redirect-step">
            <div>Tap the three dots (⋮) in the top right corner</div>
            <div class="step-icon">⋮</div>
          </div>
          <div class="redirect-step">
            <div>Select "Open in Chrome"</div>
            <div class="step-icon">🌐</div>
          </div>
        `;
      }
    } else if (browserName === 'Facebook') {
      if (iOS) {
        instructions = `
          <div class="redirect-step">
            <div>Tap the three dots (•••) in the bottom right</div>
            <div class="step-icon">⋯</div>
          </div>
          <div class="redirect-step">
            <div>Select "Open in Safari"</div>
            <div class="step-icon">🧭</div>
          </div>
        `;
      } else if (isAndroid) {
        instructions = `
          <div class="redirect-step">
            <div>Tap the three dots (⋮) in the top right corner</div>
            <div class="step-icon">⋮</div>
          </div>
          <div class="redirect-step">
            <div>Select "Open in external browser"</div>
            <div class="step-icon">🌐</div>
          </div>
        `;
      }
    } else if (browserName === 'LinkedIn') {
      instructions = `
        <div class="redirect-step">
          <div>Tap the three dots (⋮) or share icon</div>
          <div class="step-icon">⋮</div>
        </div>
        <div class="redirect-step">
          <div>Select "Open in ${iOS ? 'Safari' : 'Chrome'}"</div>
          <div class="step-icon">${iOS ? '🧭' : '🌐'}</div>
        </div>
      `;
    } else {
      // Generic instructions
      instructions = `
        <div class="redirect-step">
          <div>Look for a menu icon (⋮ or •••) in the app</div>
          <div class="step-icon">⋮</div>
        </div>
        <div class="redirect-step">
          <div>Select "Open in ${iOS ? 'Safari' : 'Chrome'}"</div>
          <div class="step-icon">${iOS ? '🧭' : '🌐'}</div>
        </div>
      `;
    }
    
    return instructions;
  }

  /**
   * Attempts to open the current URL in the default browser
   */
  window.attemptBrowserRedirect = function() {
    const currentUrl = window.location.href;
    const iOS = isIOS();
    const isAndroid = /Android/.test(navigator.userAgent);
    
    if (isAndroid) {
      // Android: Try Chrome Intent URL
      const host = window.location.host;
      const path = window.location.pathname + window.location.search + window.location.hash;
      const chromeIntent = `intent://${host}${path}#Intent;scheme=https;package=com.android.chrome;end`;
      
      window.location.href = chromeIntent;
      
      // Fallback after delay
      setTimeout(() => {
        const genericIntent = `intent://${host}${path}#Intent;scheme=https;action=android.intent.action.VIEW;end`;
        window.location.href = genericIntent;
      }, 1000);
      
    } else if (iOS) {
      // iOS: Try window.open with _system target
      window.open(currentUrl, '_system');
    }
  };

  /**
   * Dismisses the redirect overlay
   */
  window.dismissRedirectOverlay = function() {
    const overlay = document.getElementById('browser-redirect-overlay');
    if (overlay) {
      overlay.style.animation = 'fadeOut 0.3s ease-out';
      setTimeout(() => overlay.remove(), 300);
    }
  };

  /**
   * Initialize the browser detection and redirect logic
   */
  function init() {
    const config = window.BROWSER_REDIRECT_CONFIG || {};
    
    // Check if feature is enabled
    if (config.enabled === false) {
      return;
    }
    
    // Check if current path is excluded
    const currentPath = window.location.pathname;
    if (config.excludePaths && config.excludePaths.some(path => currentPath.startsWith(path))) {
      return;
    }
    
    const detection = detectInAppBrowser();
    
    if (detection.isInApp) {
      console.log(`[PWA Install] Detected in-app browser: ${detection.browser}`);
      
      // Show overlay with instructions (if enabled)
      if (config.showOverlay !== false) {
        const delay = config.overlayDelay || 0;
        setTimeout(() => showBrowserRedirectOverlay(detection.browser), delay);
      }
      
      // Log analytics event if available and enabled
      if (config.analytics !== false && window.gtag) {
        const eventName = (config.analytics && config.analytics.eventName) || 'in_app_browser_detected';
        window.gtag('event', eventName, {
          browser: detection.browser,
          user_agent: navigator.userAgent
        });
      }
    }
  }

  // Run detection when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
