import 'package:flutter/material.dart';

class AppColors {
  // CookMate Brand Colors (Dark Orange Palette)
  static const Color background = Color(0xFF0E0E0E);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF141414);
  static const Color border = Color(0xFF262626);
  static const Color imagePlaceholder = Color(0xFF24201D);

  // Primary & Accent Colors (Matching #E50915 Logo & App Icon)
  static const Color primary = Color(0xFFE50915);      // Brand Red / Logo Color
  static const Color primaryOrange = Color(0xFFE50915); // Backward compatibility
  static const Color secondary = Color(0xFFFF2E36);    // Secondary Accent
  static const Color secondaryOrange = Color(0xFFFF2E36); // Backward compatibility
  static const Color primaryLight = Color(0xFFFF5258);
  static const Color primaryDark = Color(0xFFB20710);
  
  // Dietary Colors
  static const Color vegGreen = Color(0xFF4CAF50);     // Green for Vegetarian
  static const Color nonVegRed = Color(0xFFE50915);    // Red for Non-Vegetarian / Logo Red
  static const Color veg = vegGreen;
  static const Color nonVeg = nonVegRed;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE50915);
  static const Color warning = Color(0xFFFFA000);
  static const Color heart = Color(0xFFE50915);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);  // White
  static const Color textSecondary = Color(0xFFA5A5A5);// Secondary text
  static const Color textMuted = Color(0xFF757575);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFA5A5A5);

  // Malnad & Heritage Accent Colors
  static const Color malnadGreen = Color(0xFF2E7D32);
  static const Color karnatakaGold = Color(0xFFFFB300);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color accentBlue = Color(0xFF29B6F6);
  static const Color accentPurple = Color(0xFFAB47BC);
  static const Color whatsappGreen = Color(0xFF25D366);

  // Light Theme Fallbacks (For consistency)
  static const Color lightBackground = Color(0xFFF9F6F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0D9D0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextMuted = Color(0xFF9E9E9E);

  // Dark Theme Tokens
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceCard = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA5A5A5);
  static const Color darkTextMuted = Color(0xFF757575);

  // Theme-aware color helpers
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color cardBackgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceCard : lightSurfaceCard;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color textMutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : lightTextMuted;
}

extension AppThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get themeBackground => AppColors.backgroundOf(this);
  Color get themeCardBackground => AppColors.cardBackgroundOf(this);
  Color get themeSurface => AppColors.surfaceOf(this);
  Color get themeBorder => AppColors.borderOf(this);
  Color get themeTextPrimary => AppColors.textPrimaryOf(this);
  Color get themeTextSecondary => AppColors.textSecondaryOf(this);
  Color get themeTextMuted => AppColors.textMutedOf(this);
}
