import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens mirrored from the CycleTrack Figma file.
class AppColors {
  AppColors._();

  // Light
  static const bgBase = Color(0xFFFFF6F9);
  static const surface = Color(0xFFFFFFFF);
  static const soft = Color(0xFFFCE8F0);
  static const brandPrimary = Color(0xFFE45A85);
  static const brandDeep = Color(0xFFC93D6C);
  static const lavender = Color(0xFF8B72C9);
  static const fertile = Color(0xFF2FB39E);
  static const ovulation = Color(0xFF7A55C9);
  static const bbt = Color(0xFFF09A3E);
  static const textPrimary = Color(0xFF301E2A);
  static const textSecondary = Color(0xFF826C78);
  static const border = Color(0xFFF2DCE6);
  static const danger = Color(0xFFD94A55);

  // Dark
  static const bgBaseDark = Color(0xFF17121A);
  static const surfaceDark = Color(0xFF231B27);
  static const softDark = Color(0xFF30222E);
  static const brandPrimaryDark = Color(0xFFF2799F);
  static const brandDeepDark = Color(0xFFE45A85);
  static const lavenderDark = Color(0xFFA78FE0);
  static const fertileDark = Color(0xFF46CDB6);
  static const ovulationDark = Color(0xFF9E7FE8);
  static const bbtDark = Color(0xFFF5B166);
  static const textPrimaryDark = Color(0xFFF6EDF3);
  static const textSecondaryDark = Color(0xFFB9A3B0);
  static const borderDark = Color(0xFF3C2C3A);
  static const dangerDark = Color(0xFFF27078);
}

/// Theme-aware accent colors that are not part of [ColorScheme].
class CycleColors extends ThemeExtension<CycleColors> {
  const CycleColors({
    required this.fertile,
    required this.ovulation,
    required this.bbt,
    required this.lavender,
    required this.soft,
    required this.border,
    required this.textSecondary,
  });

  final Color fertile;
  final Color ovulation;
  final Color bbt;
  final Color lavender;
  final Color soft;
  final Color border;
  final Color textSecondary;

  static const light = CycleColors(
    fertile: AppColors.fertile,
    ovulation: AppColors.ovulation,
    bbt: AppColors.bbt,
    lavender: AppColors.lavender,
    soft: AppColors.soft,
    border: AppColors.border,
    textSecondary: AppColors.textSecondary,
  );

  static const dark = CycleColors(
    fertile: AppColors.fertileDark,
    ovulation: AppColors.ovulationDark,
    bbt: AppColors.bbtDark,
    lavender: AppColors.lavenderDark,
    soft: AppColors.softDark,
    border: AppColors.borderDark,
    textSecondary: AppColors.textSecondaryDark,
  );

  @override
  CycleColors copyWith({
    Color? fertile,
    Color? ovulation,
    Color? bbt,
    Color? lavender,
    Color? soft,
    Color? border,
    Color? textSecondary,
  }) {
    return CycleColors(
      fertile: fertile ?? this.fertile,
      ovulation: ovulation ?? this.ovulation,
      bbt: bbt ?? this.bbt,
      lavender: lavender ?? this.lavender,
      soft: soft ?? this.soft,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  CycleColors lerp(ThemeExtension<CycleColors>? other, double t) {
    if (other is! CycleColors) return this;
    return CycleColors(
      fertile: Color.lerp(fertile, other.fertile, t)!,
      ovulation: Color.lerp(ovulation, other.ovulation, t)!,
      bbt: Color.lerp(bbt, other.bbt, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension CycleColorsX on BuildContext {
  CycleColors get cycleColors => Theme.of(this).extension<CycleColors>()!;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primary, Color secondary) {
    final poppins = GoogleFonts.poppinsTextTheme();
    final inter = GoogleFonts.interTextTheme();
    return TextTheme(
      displayLarge: poppins.displayLarge!
          .copyWith(fontWeight: FontWeight.w600, color: primary, fontSize: 40),
      headlineMedium: poppins.headlineMedium!
          .copyWith(fontWeight: FontWeight.w600, color: primary, fontSize: 24),
      titleLarge: poppins.titleLarge!
          .copyWith(fontWeight: FontWeight.w600, color: primary, fontSize: 18),
      titleMedium: poppins.titleMedium!
          .copyWith(fontWeight: FontWeight.w500, color: primary, fontSize: 15),
      bodyLarge: inter.bodyLarge!.copyWith(color: primary, fontSize: 15),
      bodyMedium: inter.bodyMedium!.copyWith(color: primary, fontSize: 14),
      bodySmall: inter.bodySmall!.copyWith(color: secondary, fontSize: 12),
      labelLarge: poppins.labelLarge!
          .copyWith(fontWeight: FontWeight.w500, color: primary, fontSize: 15),
      labelSmall: inter.labelSmall!.copyWith(
          color: secondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2),
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.brandPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.lavender,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.soft,
      error: AppColors.danger,
      outline: AppColors.border,
    );
    return _base(scheme, AppColors.bgBase, CycleColors.light,
        _textTheme(AppColors.textPrimary, AppColors.textSecondary));
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.brandPrimaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.lavenderDark,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.softDark,
      error: AppColors.dangerDark,
      outline: AppColors.borderDark,
    );
    return _base(scheme, AppColors.bgBaseDark, CycleColors.dark,
        _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark));
  }

  static ThemeData _base(ColorScheme scheme, Color scaffoldBg,
      CycleColors cycleColors, TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      extensions: [cycleColors],
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cycleColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: cycleColors.soft,
        side: BorderSide(color: cycleColors.border),
        labelStyle: textTheme.bodyMedium,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: cycleColors.soft,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        height: 68,
      ),
      dividerTheme: DividerThemeData(color: cycleColors.border, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.surface),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary
                : cycleColors.border),
      ),
    );
  }
}
