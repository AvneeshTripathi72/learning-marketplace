import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        primary: AppColors.lightAccentPrimary,
        secondary: AppColors.lightAccentAlt,
        error: AppColors.lightError,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onPrimary: Colors.white,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightElevatedSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerColor: AppColors.lightDivider,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        primary: AppColors.darkAccentPrimary,
        secondary: AppColors.darkAccentAlt,
        error: AppColors.darkError,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onPrimary: AppColors.darkBackground,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkElevatedSurface,
        elevation: 0, // Avoid shadows in dark mode, use surface layering
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerColor: AppColors.darkDivider,
    );
  }
}
