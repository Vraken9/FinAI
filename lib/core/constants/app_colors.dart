import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF1A1A2E);      // Dark navy
  static const primaryAccent = Color(0xFF639922); // Green accent
  static const secondary = Color(0xFF185FA5);     // Blue

  // Semantic
  static const income = Color(0xFF3B6D11);         // Dark green
  static const expense = Color(0xFFA32D2D);         // Dark red
  static const transfer = Color(0xFF185FA5);        // Blue
  static const warning = Color(0xFFBA7517);         // Amber
  
  // Neutrals
  static const surface = Color(0xFFF8F8F6);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const textSecondary = Colors.grey;
  
  // Budget status
  static const budgetSafe = Color(0xFF3B6D11);     // < 60%
  static const budgetWarning = Color(0xFFBA7517);  // 60–90%
  static const budgetOver = Color(0xFFA32D2D);     // > 90%
}
