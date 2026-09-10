// lib/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE53935); // Red (brand)

  // ── Dark Mode Surface Colors ──────────────────────────────────────────────
  static const Color darkBackground  = Color(0xFF121212);
  static const Color darkSurface     = Color(0xFF1E1E1E);
  static const Color darkAppBar      = Color(0xFF1A1A1A);
  static const Color darkCard        = Color(0xFF1E1E1E);
  static const Color darkInput       = Color(0xFF2A2A2A);
  static const Color darkDivider     = Color(0xFF2C2C2C);

  // ── Light Mode Surface Colors ─────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightAppBar     = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightInput      = Color(0xFFF0F0F0);
  static const Color lightDivider    = Color(0xFFE0E0E0);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color lightTextPrimary  = Color(0xFF212121);
  static const Color lightTextSecondary= Color(0xFF757575);

  // ── Tool Accent Colors ────────────────────────────────────────────────────
  static const Color pdfToWord   = Color(0xFFE53935); // Red
  static const Color wordToPdf   = Color(0xFF1E88E5); // Blue
  static const Color imageToPdf  = Color(0xFF43A047); // Green
  static const Color pdfToImage  = Color(0xFFFB8C00); // Orange
  static const Color compressPdf = Color(0xFF8E24AA); // Purple
  static const Color mergePdfs   = Color(0xFF00897B); // Teal
  static const Color splitPdf    = Color(0xFFD81B60); // Pink
  static const Color jpgToPng    = Color(0xFF3949AB); // Indigo
  static const Color pngToJpg    = Color(0xFF00ACC1); // Cyan
  static const Color pdfToPpt    = Color(0xFFF9A825); // Yellow
  static const Color pptToPdf    = Color(0xFFF4511E); // Deep Orange
  static const Color excelToPdf  = Color(0xFF2E7D32); // Dark Green

  // ── Hero Banner Gradient ──────────────────────────────────────────────────
  static const List<Color> bannerGradient = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
  ];

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color error   = Color(0xFFE53935);
  static const Color warning = Color(0xFFF9A825);

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns a 30% opacity version of any accent color (for button shadows).
  static Color withOpacity30(Color color) => color.withValues(alpha: 0.30);
}