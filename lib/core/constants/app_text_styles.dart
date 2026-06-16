import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Semua text style menggunakan Google Fonts: Inter
  static TextStyle headline1 = GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w500, letterSpacing: -0.5,
  );
  static TextStyle amountLarge = GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w500, letterSpacing: -1,
  );
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
}
