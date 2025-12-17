import 'package:flutter/material.dart';
import 'constants.dart';

/// Light Theme Data
/// Light mode theme configuration
final ThemeData lightTheme = ThemeData(
  // ==========================================================================
  // COLOR SCHEME
  // ==========================================================================
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    onSurface: Colors.black87,
  ),

  // ==========================================================================
  // APP BAR THEME
  // ==========================================================================
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: kHeadingFontSize,
      fontWeight: FontWeight.bold,
    ),
  ),

  // ==========================================================================
  // BUTTON THEMES
  // ==========================================================================
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 1.5,
        vertical: kDefaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: kBodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // ==========================================================================
  // INPUT DECORATION THEME
  // ==========================================================================
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(kDefaultPadding),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kErrorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kErrorColor, width: 2),
    ),
    labelStyle: const TextStyle(
      color: Colors.grey,
      fontSize: kBodyFontSize,
    ),
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: kBodyFontSize,
    ),
  ),

  // ==========================================================================
  // TEXT THEME
  // ==========================================================================
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: kHeadingFontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    headlineMedium: TextStyle(
      fontSize: kSubheadingFontSize,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
    ),
  ),

  useMaterial3: true,
);

/// Dark Theme Data
/// Dark mode theme configuration matching the modern dark design
final ThemeData darkTheme = ThemeData(
  // ==========================================================================
  // COLOR SCHEME
  // ==========================================================================
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kDarkBackgroundColor,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    surface: kDarkCardColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    onSurface: Colors.white,
  ),

  // ==========================================================================
  // APP BAR THEME
  // ==========================================================================
  appBarTheme: AppBarTheme(
    backgroundColor: kDarkCardColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: kHeadingFontSize,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  // ==========================================================================
  // BUTTON THEMES
  // ==========================================================================
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 1.5,
        vertical: kDefaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: kBodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // ==========================================================================
  // INPUT DECORATION THEME
  // ==========================================================================
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDarkCardColor,
    contentPadding: const EdgeInsets.all(kDefaultPadding),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[800]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kErrorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kErrorColor, width: 2),
    ),
    labelStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: kBodyFontSize,
    ),
    hintStyle: TextStyle(
      color: Colors.grey[600],
      fontSize: kBodyFontSize,
    ),
  ),

  // ==========================================================================
  // TEXT THEME
  // ==========================================================================
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: kHeadingFontSize,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: kSubheadingFontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  ),

  // ==========================================================================
  // CARD THEME
  // ==========================================================================
  cardTheme: CardThemeData(
    color: kDarkCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // ==========================================================================
  // DIVIDER THEME
  // ==========================================================================
  dividerTheme: DividerThemeData(
    color: Colors.grey[800],
    thickness: 1,
  ),

  useMaterial3: true,
);

/// Legacy appTheme for backward compatibility
/// Defaults to dark theme
final ThemeData appTheme = darkTheme;
