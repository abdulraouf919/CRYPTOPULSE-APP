import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1976D2), // blue.shade700
    Color(0xFF0D47A1), // blue.shade900
  ];

  // Gradients
  static const LinearGradient standardGradient = LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dimensions
  static const double cardBorderRadius = 12.0;
  static const double largeCardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double appBarElevation = 0.0;

  // Padding
  static const EdgeInsets standardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(32.0);

  // Shadows
  static const List<BoxShadow> standardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  static const List<BoxShadow> gradientShadow = [
    BoxShadow(
      color: Color(0x42000000), // blue with opacity
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // Text Styles
  static const TextStyle whiteTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle white70TextStyle = TextStyle(
    color: Colors.white70,
  );

  // User ID (for testing)
  static const int testUserId = 1;
} 