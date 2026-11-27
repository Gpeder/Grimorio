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
        errorBorder: const OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: AppColors.vida),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: AppColors.vida, width: 2),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.vida),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.45),
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onSurface
              : AppColors.onSurface.withValues(alpha: 0.6),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.background,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.alerta
              : AppColors.secondary.withValues(alpha: 0.5),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.alerta
              : AppColors.secondary.withValues(alpha: 0.6),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface.withValues(alpha: 0.7),
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.alerta),
          shape: alertShape,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.secondary.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.8),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.radiusLarge),
          ),
          side: BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }
}
