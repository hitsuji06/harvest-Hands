import 'package:flutter/material.dart';

class AppTheme {
  static const _sageGreen = Color(0xFFA8B89B);
  static const _wheatGold = Color(0xFFD4A93A);
  static const _lavender = Color(0xFF9B7FB8);
  static const _creamWhite = Color(0xFFFAF6EC);
  static const _deepBrown = Color(0xFF3D2817);
  static const _darkBg = Color(0xFF1A1410);
  static const _lightCream = Color(0xFFF5E9D0);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _sageGreen,
          primary: _sageGreen,
          secondary: _wheatGold,
          tertiary: _lavender,
          surface: _creamWhite,
          onSurface: _deepBrown,
          brightness: Brightness.light,
        ).copyWith(
          error: const Color(0xFFB00020),
          tertiary: _lavender,
          onTertiary: Colors.white,
        ),
        scaffoldBackgroundColor: _creamWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: _sageGreen,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _sageGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _sageGreen,
            side: const BorderSide(color: _sageGreen),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          iconColor: _deepBrown,
          prefixIconColor: const Color(0xFF6B7C64),
          suffixIconColor: const Color(0xFF6B7C64),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCCC5B9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCCC5B9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _sageGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB00020)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB00020), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0x26A8B89B), // sageGreen 15%
          labelStyle: const TextStyle(color: _deepBrown),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _wheatGold,
          foregroundColor: Colors.white,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0x33A8B89B), // sageGreen 20%
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0x33A8B89B),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? _sageGreen : const Color(0xFF6B7C64),
            );
          }),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: _deepBrown, fontSize: 12),
          ),
        ),
        extensions: const [AppColors.light],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _sageGreen,
          primary: const Color(0xFFB8C8AB),
          secondary: const Color(0xFFE6BC4D),
          tertiary: const Color(0xFFB199CC),
          surface: _darkBg,
          onSurface: _lightCream,
          brightness: Brightness.dark,
        ).copyWith(
          error: const Color(0xFFCF6679),
        ),
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A1F16),
          foregroundColor: _lightCream,
          iconTheme: IconThemeData(color: _lightCream),
          actionsIconTheme: IconThemeData(color: _lightCream),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB8C8AB),
            foregroundColor: _darkBg,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB8C8AB),
            side: const BorderSide(color: Color(0xFFB8C8AB)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A1F16),
          iconColor: _lightCream,
          prefixIconColor: const Color(0xFFB8C8AB),
          suffixIconColor: const Color(0xFFB8C8AB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5A4A3A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5A4A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB8C8AB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF6679)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
          ),
          labelStyle: const TextStyle(color: _lightCream),
          hintStyle: const TextStyle(color: Color(0x80F5E9D0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A1F16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0x33B8C8AB), // sage 20%
          labelStyle: const TextStyle(color: _lightCream),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF2A1F16),
          contentTextStyle: const TextStyle(color: _lightCream),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE6BC4D),
          foregroundColor: _darkBg,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0x33B8C8AB), // sage 20%
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF2A1F16),
          indicatorColor: const Color(0x33B8C8AB),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? const Color(0xFFB8C8AB) : const Color(0xFF8FA080),
            );
          }),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: _lightCream, fontSize: 12),
          ),
        ),
        extensions: const [AppColors.dark],
      );
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color placeholder;
  final Color accentAmber;
  final Color tagBackground;

  const AppColors({
    required this.placeholder,
    required this.accentAmber,
    required this.tagBackground,
  });

  static const light = AppColors(
    placeholder: Color(0xFFA8B89B),
    accentAmber: Color(0xFFC8893E),
    tagBackground: Color(0xFFEDE9DF),
  );

  static const dark = AppColors(
    placeholder: Color(0xFF4A5E42),
    accentAmber: Color(0xFFD4A050),
    tagBackground: Color(0xFF3A2E22),
  );

  @override
  AppColors copyWith({Color? placeholder, Color? accentAmber, Color? tagBackground}) {
    return AppColors(
      placeholder: placeholder ?? this.placeholder,
      accentAmber: accentAmber ?? this.accentAmber,
      tagBackground: tagBackground ?? this.tagBackground,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
    );
  }
}
