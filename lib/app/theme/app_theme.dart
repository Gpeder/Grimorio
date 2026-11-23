import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static final ThemeData dark = _build();

  static ThemeData _build() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onSurface,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );
    final textTheme = AppTypography.textTheme(base.textTheme);

    const radius = BorderRadius.all(Radius.circular(AppSpacing.small));
    const shape = RoundedRectangleBorder(borderRadius: radius);
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.large,
      vertical: AppSpacing.medium,
    );
    final buttonStyle = ButtonStyle(
      padding: const WidgetStatePropertyAll(buttonPadding),
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(shape),
    );

    const alertBorder = BorderSide(color: AppColors.alerta, width: 2);
    const alertShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSmall)),
    );
    const actionPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    const actionMinSize = Size(64, 48);
    final actionTextStyle = textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onSurface,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.38),
      disabledForegroundColor: AppColors.onSurface.withValues(alpha: 0.5),
      overlayColor: AppColors.onSurface,
      elevation: 0,
      padding: actionPadding,
      minimumSize: actionMinSize,
      shape: alertShape,
      textStyle: actionTextStyle,
    );

    final outlinedButtonStyle =
        OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.alerta,
          disabledForegroundColor: AppColors.alerta.withValues(alpha: 0.38),
          overlayColor: AppColors.alerta,
          padding: actionPadding,
          minimumSize: actionMinSize,
          shape: alertShape,
          textStyle: actionTextStyle,
        ).copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? BorderSide(
                    color: AppColors.alerta.withValues(alpha: 0.38),
                    width: 2,
                  )
                : alertBorder,
          ),
        );

    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      padding: const EdgeInsets.all(8),
      side: alertBorder,
      shape: alertShape,
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
      iconButtonTheme: IconButtonThemeData(style: iconButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(),
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.alerta,
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.all(AppSpacing.small),
        shape: shape,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.secondary.withValues(alpha: 0.25),
        thickness: 1,
        space: AppSpacing.large,
      ),
    );
  }
}
