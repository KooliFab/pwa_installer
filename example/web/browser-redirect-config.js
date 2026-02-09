/**
 * Browser Redirect Configuration
 * 
 * Customize the behavior and appearance of the in-app browser redirect feature.
 * 
 * USAGE: Copy this file to your web/ directory and customize as needed.
 */

window.BROWSER_REDIRECT_CONFIG = {
  // Enable or disable the redirect feature globally
  enabled: true,
  
  // Show overlay automatically when in-app browser is detected
  showOverlay: true,
  
  // Allow users to dismiss the overlay and continue anyway
  allowDismiss: true,
  
  // Delay before showing overlay (in milliseconds)
  overlayDelay: 0,
  
  // Custom colors (optional - defaults provided)
  colors: {
    primary: '#1A1D32',      // Background gradient start
    accent: '#FF7A5A',       // Accent color for buttons/highlights
    surface: '#1E1E1E',      // Card/surface background
    text: '#FFFFFF'          // Text color
  },
  
  // Custom messages (optional - defaults provided)
  messages: {
    titleAccent: 'Open in',
    titleMain: ' Browser',
    message: 'For the best experience and to enable all features, please open this link in your default browser.'
  },
  
  // Analytics integration (optional)
  // Requires Google Analytics gtag.js to be loaded
  analytics: {
    enabled: true,
    eventName: 'in_app_browser_detected'
  },
  
  // Exclude specific paths from showing the overlay
  excludePaths: [
    // '/admin',
    // '/api'
  ]
};
