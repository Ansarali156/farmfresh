// This file defines the centralized color palette for the farm products marketplace.
// It includes primary greens, secondary colors, backgrounds, and text colors.
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32); // A rich, organic green
  static const Color lightGreen = Color(0xFF60AD5E);
  static const Color darkGreen = Color(0xFF005005);
  
  static const Color accentOrange = Color(0xFFFF9800); // Earthy orange for highlights

  // Background Colors - Light
  static const Color backgroundLight = Color(0xFFF1F8E9); // Very light greenish tint
  static const Color surfaceLight = Colors.white;

  // Background Colors - Dark
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}
