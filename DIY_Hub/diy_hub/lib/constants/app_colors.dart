// lib/constants/app_colors.dart
// Central color palette for DIYHub's comic-book visual style.
// Every screen/widget should pull colors from here — never hardcode hex values elsewhere.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Core comic brand colors (used across both themes) ──────────────
  static const Color comicYellow = Color(0xFFFFC107);
  static const Color comicBlue = Color(0xFF1E88E5);
  static const Color comicRed = Color(0xFFE53935);
  static const Color comicGreen = Color(0xFF43A047);
  static const Color comicOrange = Color(0xFFFB8C00);
  static const Color comicPurple = Color(0xFF8E24AA);

  // ── Light comic mode ─────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F0E1); // cream/off-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightAppBar = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightDivider = Color(0xFFE0DCC8);
  static const Color lightOutline = Color(0xFF000000); // bold black outlines
  static const Color lightHalftoneDot = Color(0x1A000000); // faint black dots

  // ── Dark comic mode ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121220);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkAppBar = Color(0xFF1A1A2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkDivider = Color(0xFF2C2C3E);
  static const Color darkOutline = Color(0xFFFFFFFF); // bright outlines on dark
  static const Color darkHalftoneDot = Color(0x1AFFFFFF); // faint white dots

  // ── Rank colors (Novice / Cadet / Master badges) ────────────────
  static const Color rankNovice = Color(0xFF43A047); // green
  static const Color rankCadet = Color(0xFF1E88E5); // blue
  static const Color rankMaster = Color(0xFFE53935); // red

  // ── Hero Tier colors (onboarding age select) ────────────────────
  static const Color tierKids = Color(0xFF1E88E5); // Rookie Builders
  static const Color tierTeens = Color(0xFFFFC107); // Maker Cadets
  static const Color tierAdult = Color(0xFF1A1A1A); // Master Artisans

  // ── Category accent colors (mission categories) ─────────────────
  static const Color categoryElectronics = Color(0xFFFDD835); // yellow/gold
  static const Color categoryHomeRepair = Color(0xFFFFCA28); // warm yellow
  static const Color categoryWoodcraft = Color(0xFFFFB300); // amber
  static const Color categoryCookingLab = Color(0xFFEF9A9A); // soft red/pink
  static const Color categoryRobotics = Color(0xFF90CAF9); // soft blue
  static const Color categoryGardening = Color(0xFF81C784); // soft green

  // ── Semantic / status colors ─────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color error = Color(0xFFE53935);
  static const Color locked = Color(0xFF9E9E9E);
}