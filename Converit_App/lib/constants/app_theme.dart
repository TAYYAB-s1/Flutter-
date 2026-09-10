// lib/constants/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Shared shape / radius ─────────────────────────────────────────────────
  static const _cardRadius    = BorderRadius.all(Radius.circular(16));
  static const _buttonRadius  = BorderRadius.all(Radius.circular(12));
  static const _inputRadius   = BorderRadius.all(Radius.circular(10));

  // ── Text Styles ───────────────────────────────────────────────────────────
  static const TextTheme _textTheme = TextTheme(
    displayLarge : TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge   : TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium  : TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium   : TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall    : TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge   : TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  );

  // ── DARK THEME ─────────────────────────────────────────────────────────────
  static ThemeData dark({Color seedColor = AppColors.primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor  : seedColor,
      brightness : Brightness.dark,
    ).copyWith(
      surface   : AppColors.darkSurface,
      onSurface : AppColors.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3      : true,
      brightness        : Brightness.dark,
      colorScheme       : colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme         : _textTheme.apply(
        bodyColor       : AppColors.darkTextPrimary,
        displayColor    : AppColors.darkTextPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor   : AppColors.darkAppBar,
        foregroundColor   : AppColors.darkTextPrimary,
        elevation         : 0,
        centerTitle       : false,
        titleTextStyle    : TextStyle(
          fontSize   : 20,
          fontWeight : FontWeight.bold,
          color      : AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color        : AppColors.darkCard,
        elevation    : 0,
        shape        : const RoundedRectangleBorder(borderRadius: _cardRadius),
        margin       : EdgeInsets.zero,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor : seedColor,
          foregroundColor : Colors.white,
          elevation       : 0,
          padding         : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape           : const RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle       : const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor : seedColor,
          side            : BorderSide(color: seedColor),
          padding         : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape           : const RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle       : const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor : seedColor,
          textStyle       : const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled          : true,
        fillColor       : AppColors.darkInput,
        border          : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide.none,
        ),
        enabledBorder   : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide.none,
        ),
        focusedBorder   : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide(color: seedColor, width: 1.5),
        ),
        hintStyle       : const TextStyle(color: AppColors.darkTextSecondary),
        contentPadding  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor      : AppColors.darkCard,
        selectedColor        : seedColor,
        labelStyle           : const TextStyle(fontSize: 13, color: AppColors.darkTextPrimary),
        secondaryLabelStyle  : const TextStyle(fontSize: 13, color: Colors.white),
        padding              : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape                : const StadiumBorder(),
        side                 : const BorderSide(color: AppColors.darkDivider),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color     : AppColors.darkDivider,
        thickness : 1,
        space     : 1,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor    : AppColors.darkAppBar,
        selectedItemColor  : seedColor,
        unselectedItemColor: AppColors.darkTextSecondary,
        type               : BottomNavigationBarType.fixed,
        elevation          : 0,
        selectedLabelStyle : const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),

      // List Tiles
      listTileTheme: const ListTileThemeData(
        tileColor       : Colors.transparent,
        textColor       : AppColors.darkTextPrimary,
        iconColor       : AppColors.darkTextSecondary,
        contentPadding  : EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Switches
      switchTheme: SwitchThemeData(
        thumbColor    : WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? seedColor : Colors.grey),
        trackColor    : WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.4)
            : AppColors.darkDivider),
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor  : seedColor,
        thumbColor        : seedColor,
        inactiveTrackColor: AppColors.darkDivider,
        overlayColor      : seedColor.withOpacity(0.2),
      ),

      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor : AppColors.darkSurface,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
        behavior        : SnackBarBehavior.floating,
        shape           : RoundedRectangleBorder(
          borderRadius  : BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  // ── LIGHT THEME ────────────────────────────────────────────────────────────
  static ThemeData light({Color seedColor = AppColors.primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor  : seedColor,
      brightness : Brightness.light,
    ).copyWith(
      surface   : AppColors.lightSurface,
      onSurface : AppColors.lightTextPrimary,
    );

    return ThemeData(
      useMaterial3      : true,
      brightness        : Brightness.light,
      colorScheme       : colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme         : _textTheme.apply(
        bodyColor       : AppColors.lightTextPrimary,
        displayColor    : AppColors.lightTextPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor   : AppColors.lightAppBar,
        foregroundColor   : AppColors.lightTextPrimary,
        elevation         : 0,
        centerTitle       : false,
        titleTextStyle    : TextStyle(
          fontSize   : 20,
          fontWeight : FontWeight.bold,
          color      : AppColors.lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        shadowColor: Color(0x1A000000),
      ),

      // Cards
      cardTheme: CardThemeData(
        color        : AppColors.lightCard,
        elevation    : 0,
        shape        : const RoundedRectangleBorder(borderRadius: _cardRadius),
        margin       : EdgeInsets.zero,
        shadowColor  : const Color(0x1A000000),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor : seedColor,
          foregroundColor : Colors.white,
          elevation       : 2,
          shadowColor     : seedColor.withOpacity(0.3),
          padding         : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape           : const RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle       : const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor : seedColor,
          side            : BorderSide(color: seedColor),
          padding         : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape           : const RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle       : const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor : seedColor,
          textStyle       : const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled          : true,
        fillColor       : AppColors.lightInput,
        border          : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide.none,
        ),
        enabledBorder   : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide.none,
        ),
        focusedBorder   : OutlineInputBorder(
          borderRadius  : _inputRadius,
          borderSide    : BorderSide(color: seedColor, width: 1.5),
        ),
        hintStyle       : const TextStyle(color: AppColors.lightTextSecondary),
        contentPadding  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor      : AppColors.lightCard,
        selectedColor        : seedColor,
        labelStyle           : const TextStyle(fontSize: 13, color: AppColors.lightTextPrimary),
        secondaryLabelStyle  : const TextStyle(fontSize: 13, color: Colors.white),
        padding              : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape                : const StadiumBorder(),
        side                 : const BorderSide(color: AppColors.lightDivider),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color     : AppColors.lightDivider,
        thickness : 1,
        space     : 1,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor    : AppColors.lightAppBar,
        selectedItemColor  : seedColor,
        unselectedItemColor: AppColors.lightTextSecondary,
        type               : BottomNavigationBarType.fixed,
        elevation          : 8,
        selectedLabelStyle : const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),

      // List Tiles
      listTileTheme: const ListTileThemeData(
        tileColor       : Colors.transparent,
        textColor       : AppColors.lightTextPrimary,
        iconColor       : AppColors.lightTextSecondary,
        contentPadding  : EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Switches
      switchTheme: SwitchThemeData(
        thumbColor    : WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? seedColor : Colors.grey),
        trackColor    : WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.4)
            : AppColors.lightDivider),
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor  : seedColor,
        thumbColor        : seedColor,
        inactiveTrackColor: AppColors.lightDivider,
        overlayColor      : seedColor.withOpacity(0.2),
      ),

      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor : AppColors.lightSurface,
        contentTextStyle: TextStyle(color: AppColors.lightTextPrimary),
        behavior        : SnackBarBehavior.floating,
        shape           : RoundedRectangleBorder(
          borderRadius  : BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}