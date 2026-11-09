// lib/constants/app_theme.dart
// Light-only neo-brutalist theme for DIYHub: square corners, thick ink
// borders, hard offset shadows (zero blur), flat colors. There is NO dark
// theme. The black header / bottom nav / Mission Player stage are fixed
// design accents drawn with AppColors.ink, not a theme variant.

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography helpers. Fonts are bundled assets (see pubspec.yaml):
///  - ArchivoBlack: display / headings (single heavy weight, UPPERCASE)
///  - JetBrainsMono: tags, tables, status text
///  - PressStart2P: big pixel counts and wordmarks (use sparingly)
/// Body text uses the platform's default sans-serif.
class AppText {
  AppText._();

  static const String displayFont = 'ArchivoBlack';
  static const String monoFont = 'JetBrainsMono';
  static const String pixelFont = 'PressStart2P';

  /// Heavy headline. Call sites should pass UPPERCASE strings.
  static TextStyle display({
    double size = 28,
    Color color = AppColors.ink,
    double height = 1.05,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: FontWeight.w400, // Archivo Black is already the heavy cut
    );
  }

  /// Card titles (16) and section titles (20-22) are just smaller displays.
  static TextStyle title({double size = 20, Color color = AppColors.ink}) =>
      display(size: size, color: color, height: 1.1);

  static TextStyle cardTitle({Color color = AppColors.ink}) =>
      display(size: 16, color: color, height: 1.15);

  /// Normal paragraph text.
  static TextStyle body({
    double size = 14,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w500,
  }) {
    return TextStyle(
        fontSize: size, color: color, height: 1.4, fontWeight: weight);
  }

  /// Secondary / muted paragraph text.
  static TextStyle bodyMuted({double size = 14}) =>
      body(size: size, color: AppColors.muted, weight: FontWeight.w400);

  /// Small captions (minimum 12).
  static TextStyle caption({Color color = AppColors.muted}) =>
      body(size: 12, color: color, weight: FontWeight.w500);

  /// Monospace tag / table / status text. Pass UPPERCASE strings.
  /// Never go below 11.
  static TextStyle tag({
    double size = 11,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: monoFont,
      fontSize: size < 11 ? 11 : size,
      color: color,
      fontWeight: weight,
      letterSpacing: 0.6,
      height: 1.2,
    );
  }

  /// Pixel font for big numbers (counts, XP) and the wordmark.
  static TextStyle pixel({double size = 20, Color color = AppColors.ink}) {
    return TextStyle(
      fontFamily: pixelFont,
      fontSize: size,
      color: color,
      height: 1.2,
      fontWeight: FontWeight.w400,
    );
  }
}

class AppTheme {
  AppTheme._();

  // ── Shape constants ───────────────────────────────────────────────
  /// Border width for cards and buttons.
  static const double borderWidth = 3;

  /// Border width for tags and inputs.
  static const double tagBorderWidth = 2;

  /// Default hard-shadow offset (right and down).
  static const double shadowOffset = 4;

  static const BorderSide border =
      BorderSide(color: AppColors.ink, width: borderWidth);
  static const BorderSide tagBorder =
      BorderSide(color: AppColors.ink, width: tagBorderWidth);

  /// Square, bordered shape used by buttons, cards, dialogs and sheets.
  static const RoundedRectangleBorder squareShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: border);

  /// A hard offset shadow: solid color, zero blur.
  static List<BoxShadow> hardShadow({
    double offset = shadowOffset,
    Color color = AppColors.ink,
  }) {
    return [
      BoxShadow(color: color, offset: Offset(offset, offset), blurRadius: 0)
    ];
  }

  /// The one and only theme. The app is light-only.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = TextTheme(
      displayLarge: AppText.display(size: 32),
      displayMedium: AppText.display(size: 28),
      titleLarge: AppText.title(size: 22),
      titleMedium: AppText.cardTitle(),
      bodyLarge: AppText.body(size: 15),
      bodyMedium: AppText.bodyMuted(),
      bodySmall: AppText.caption(),
      labelLarge: AppText.tag(size: 12),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      canvasColor: AppColors.cream,
      splashFactory: NoSplash.splashFactory, // flat style: no ripples
      highlightColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.ink,
        onPrimary: AppColors.white,
        secondary: AppColors.actionYellow,
        onSecondary: AppColors.ink,
        surface: AppColors.white,
        onSurface: AppColors.ink,
        error: AppColors.danger,
        onError: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppText.display(size: 18, color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: squareShape,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionYellow,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.locked,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: squareShape,
          splashFactory: NoSplash.splashFactory,
          textStyle: AppText.display(size: 15, height: 1.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.locked,
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: squareShape,
          side: border,
          splashFactory: NoSplash.splashFactory,
          textStyle: AppText.display(size: 15, height: 1.1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          splashFactory: NoSplash.splashFactory,
          textStyle: AppText.tag(size: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppText.tag(
            size: 12, color: AppColors.muted, weight: FontWeight.w400),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero, borderSide: tagBorder),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero, borderSide: tagBorder),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero, borderSide: border),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.actionYellow,
        labelStyle: AppText.tag(),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, side: tagBorder),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.ink, thickness: 2, space: 2),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: squareShape,
        titleTextStyle: AppText.title(size: 20),
        contentTextStyle: AppText.body(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: squareShape,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.tag(size: 12, color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.actionYellow, width: 2),
        ),
      ),
      // Used by the old bottom bar until AppBottomNav replaces it.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.ink,
        selectedItemColor: AppColors.actionYellow,
        unselectedItemColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: AppText.tag(size: 11),
        unselectedLabelStyle: AppText.tag(size: 11, weight: FontWeight.w400),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.white,
      ),
    );
  }
}
