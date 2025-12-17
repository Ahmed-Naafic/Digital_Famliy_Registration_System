import 'package:flutter/material.dart';
import 'constants.dart';

/// App theme configuration
/// This file defines the global theme for the entire application using constants
/// from constants.dart to ensure design consistency

/// Main theme data for the application
/// This theme is applied globally through MaterialApp's theme property
final ThemeData appTheme = ThemeData(
  // ==========================================================================
  // COLOR SCHEME
  // ==========================================================================
  
  /// Primary color used throughout the app
  primaryColor: kPrimaryColor,
  
  /// Background color for scaffold (main screen background)
  scaffoldBackgroundColor: kBackgroundColor,
  
  /// Color scheme that defines the app's color palette
  /// This is used by Material widgets to determine their default colors
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
  
  /// Theme for AppBar widgets throughout the app
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
  
  /// Theme for ElevatedButton widgets
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
  
  /// Theme for TextField and form input fields
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
  
  /// Theme for text styles used throughout the app
  textTheme: const TextTheme(
    // Headline styles - for main titles
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
    // Body styles - for regular text content
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

  // ==========================================================================
  // USE MATERIAL 3
  // ==========================================================================
  
  /// Enable Material Design 3 features
  useMaterial3: true,
);


