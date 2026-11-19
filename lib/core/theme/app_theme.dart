import 'package:flutter/material.dart';

/// CarAid design tokens.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1B3348);
  static const ink = Color(0xFF16212D);
  static const muted = Color(0xFF6B7B8C);
  static const faint = Color(0xFF97A6B5);
  static const cloud = Color(0xFFF4F7FA);
  static const border = Color(0xFFE6ECF2);
  static const white = Colors.white;

  static const teal = Color(0xFF11B39A);
  static const tealDark = Color(0xFF0B8B78);
  static const tealSoft = Color(0xFFE3F7F3);

  static const amber = Color(0xFFFFB020);
  static const amberSoft = Color(0xFFFFF3DC);
  static const orange = Color(0xFFFF7A3D);
  static const coral = Color(0xFFFF5E5B);
  static const coralSoft = Color(0xFFFFECEB);
  static const purple = Color(0xFF7C5CFC);
  static const purpleSoft = Color(0xFFEFEAFF);
  static const blue = Color(0xFF2F80ED);
  static const blueSoft = Color(0xFFE8F1FE);

  // Payment brands (approximation of the real identities).
  static const bkash = Color(0xFFE2136E);
  static const nagad = Color(0xFFED6B22);
  static const rocket = Color(0xFF8C3494);
  static const cash = Color(0xFF159A6B);

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1826), Color(0xFF14324A)],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF17C7AC), Color(0xFF0A917C)],
  );

  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC44D), Color(0xFFFF8A2B)],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2A3A), Color(0xFF0D1B2A), Color(0xFF2A1D0E)],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: ink.withOpacity(0.06),
          blurRadius: 26,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get liftShadow => [
        BoxShadow(
          color: ink.withOpacity(0.10),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ];
}

class AppText {
  AppText._();

  static const _display = 'UberMove';

  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      TextStyle(
        fontFamily: _display,
        fontSize: size,
        height: 1.12,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle h1({Color color = AppColors.ink}) => display(28, color: color);

  static TextStyle h2({Color color = AppColors.ink}) => display(22, color: color);

  static TextStyle h3({Color color = AppColors.ink}) => display(18, color: color);

  static TextStyle body(
          {double size = 14,
          Color color = AppColors.ink,
          FontWeight weight = FontWeight.w400,
          double height = 1.45}) =>
      TextStyle(
        fontSize: size,
        height: height,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.05,
      );

  static TextStyle label(
          {double size = 12,
          Color color = AppColors.muted,
          FontWeight weight = FontWeight.w600,
          double letterSpacing = 0.2}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle price({Color color = AppColors.ink, double size = 18}) =>
      display(size, color: color);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.teal,
      secondary: AppColors.amber,
      surface: AppColors.white,
      background: AppColors.cloud,
      error: AppColors.coral,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cloud,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cloud,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: AppText.h3(),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.body(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppText.body(color: AppColors.faint),
        labelStyle: AppText.body(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.4),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearTrackColor: AppColors.border,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.teal,
        labelStyle: AppText.label(
            size: 14, color: AppColors.ink, weight: FontWeight.w700),
        unselectedLabelStyle:
            AppText.label(size: 14, color: AppColors.muted, weight: FontWeight.w600),
      ),
    );
  }
}
