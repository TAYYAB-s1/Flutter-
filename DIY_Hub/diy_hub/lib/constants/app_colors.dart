// lib/constants/app_colors.dart
// Central color palette for DIYHub's light neo-brutalist arcade style.
// Every screen/widget must take colors from here, never hardcode hex values.
//
// Hex values are approximated from the design reference, so tweak them here
// and the whole app updates.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Core tokens ──────────────────────────────────────────────────
  /// Page background (warm cream).
  static const Color cream = Color(0xFFF1EFE7);

  /// Ink black: text, borders, hard shadows, header, bottom nav, player stage.
  static const Color ink = Color(0xFF0A0A0A);

  /// Card / input surface.
  static const Color white = Color(0xFFFFFFFF);

  /// Secondary text.
  static const Color muted = Color(0xFF5B5B57);

  /// Action yellow: ONLY for primary buttons, the dice button, the active
  /// bottom-nav tab and hazard stripes.
  static const Color actionYellow = Color(0xFFFFD93D);

  /// Faint ink dots used by the halftone pattern (about 15% opacity).
  static const Color halftoneDot = Color(0x260A0A0A);

  /// Faint white lines used by the pixel grid on the black stage.
  static const Color stageGrid = Color(0x14FFFFFF);

  // ── Category colors (flat fills) ────────────────────────────────
  static const Color categoryElectronics = Color(0xFFA78BFA); // purple
  static const Color categoryHomeRepair = Color(0xFFF0504A); // red
  static const Color categoryWoodcraft = Color(0xFFFF9F43); // orange
  static const Color categoryCookingLab = Color(0xFFF472B6); // pink
  static const Color categoryRobotics = Color(0xFF38A3F0); // blue
  static const Color categoryGardening = Color(0xFF34D27B); // green

  // ── Status colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF34D27B); // completed
  static const Color danger = Color(0xFFF0504A); // destructive
  static const Color locked = Color(0xFFB8B5AA); // locked / disabled
  static const Color inProgress = Color(0xFF38A3F0); // in-progress pill

  // ── Rank colors (rank card on the Progress screen) ──────────────
  static const Color rankNovice = Color(0xFF34D27B);
  static const Color rankCadet = Color(0xFFA78BFA);
  static const Color rankMaster = Color(0xFFF0504A);

  // ── Hero Tier colors (onboarding cards) ─────────────────────────
  static const Color tierKids = Color(0xFF34D27B); // Rookie Builders
  static const Color tierTeens = Color(0xFF38A3F0); // Maker Cadets
  static const Color tierAdult = Color(0xFFF472B6); // Master Artisans

  // ═════════════════════════════════════════════════════════════
  // LEGACY ALIASES
  // The screens from the comic-style version still use these names.
  // They are mapped onto the new palette so the app keeps compiling
  // while each screen is restyled. Remove them once every screen has
  // been migrated (Phase F).
  // ═════════════════════════════════════════════════════════════
  static const Color comicYellow = actionYellow;
  static const Color comicBlue = categoryRobotics;
  static const Color comicRed = danger;
  static const Color comicGreen = success;
  static const Color comicOrange = categoryWoodcraft;
  static const Color comicPurple = categoryElectronics;

  static const Color lightBackground = cream;
  static const Color lightSurface = white;
  static const Color lightAppBar = ink;
  static const Color lightTextPrimary = ink;
  static const Color lightTextSecondary = muted;
  static const Color lightDivider = Color(0xFFD6D2C4);
  static const Color lightOutline = ink;
  static const Color lightHalftoneDot = halftoneDot;

  // Dark values are unused (the app is light-only) but kept so old
  // `isDark ? dark : light` expressions still compile.
  static const Color darkBackground = ink;
  static const Color darkSurface = Color(0xFF161616);
  static const Color darkAppBar = ink;
  static const Color darkTextPrimary = white;
  static const Color darkTextSecondary = Color(0xFFB8B5AA);
  static const Color darkDivider = Color(0xFF2A2A2A);
  static const Color darkOutline = white;
  static const Color darkHalftoneDot = Color(0x1AFFFFFF);

  static const Color error = danger;
  static const Color warning = categoryWoodcraft;
}
