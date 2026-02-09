import 'package:flutter/material.dart';

/// Configurable theme for PWA install widgets.
///
/// Allows customization of colors, gradients, and text styles
/// while providing sensible defaults.
class PwaInstallerTheme {
  /// Primary color used for highlights and accents.
  final Color primaryColor;

  /// Secondary/accent color used for buttons and icons.
  final Color accentColor;

  /// Background color for cards and containers.
  final Color surfaceColor;

  /// Dark surface color for mockup elements.
  final Color darkSurfaceColor;

  /// Primary text color.
  final Color textColor;

  /// Secondary/muted text color.
  final Color secondaryTextColor;

  /// Background gradient for screens.
  final Gradient? backgroundGradient;

  /// Background color when not using gradient.
  final Color backgroundColor;

  /// Border radius for cards and containers.
  final double borderRadius;

  /// Padding for content areas.
  final EdgeInsets contentPadding;

  const PwaInstallerTheme({
    this.primaryColor = const Color(0xFF1A1D32),
    this.accentColor = const Color(0xFFFF7A5A),
    this.surfaceColor = const Color(0xFF1E1E1E),
    this.darkSurfaceColor = const Color(0xFF2A2A3A),
    this.textColor = Colors.white,
    this.secondaryTextColor = const Color(0xFF9E9E9E),
    this.backgroundGradient,
    this.backgroundColor = const Color(0xFF1A1D32),
    this.borderRadius = 12.0,
    this.contentPadding = const EdgeInsets.all(24.0),
  });

  /// Default theme with a dark gradient background.
  static PwaInstallerTheme get defaultTheme => const PwaInstallerTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1D32), Color(0xFF725D78)],
        ),
      );

  /// Light theme variant.
  static PwaInstallerTheme get lightTheme => const PwaInstallerTheme(
        primaryColor: Color(0xFF3D5A80),
        accentColor: Color(0xFFFF7A5A),
        surfaceColor: Colors.white,
        darkSurfaceColor: Color(0xFFF5F5F5),
        textColor: Color(0xFF1A1A1A),
        secondaryTextColor: Color(0xFF757575),
        backgroundColor: Colors.white,
        backgroundGradient: null,
      );

  /// Creates a theme from the app's current theme context.
  factory PwaInstallerTheme.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    return PwaInstallerTheme(
      primaryColor: theme.colorScheme.primary,
      accentColor: theme.colorScheme.secondary,
      surfaceColor: theme.colorScheme.surface,
      darkSurfaceColor: theme.colorScheme.surfaceContainer,
      textColor: theme.colorScheme.onSurface,
      secondaryTextColor: theme.colorScheme.onSurfaceVariant,
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  /// Creates a copy of this theme with the given fields replaced.
  PwaInstallerTheme copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? surfaceColor,
    Color? darkSurfaceColor,
    Color? textColor,
    Color? secondaryTextColor,
    Gradient? backgroundGradient,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? contentPadding,
  }) {
    return PwaInstallerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      darkSurfaceColor: darkSurfaceColor ?? this.darkSurfaceColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
