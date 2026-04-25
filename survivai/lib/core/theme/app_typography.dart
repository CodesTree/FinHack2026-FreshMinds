import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle headlineXl = GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.6,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.outfit(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.64,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodyBase = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelCaps = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: 3.0,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );
}
