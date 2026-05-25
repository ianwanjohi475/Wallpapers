import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'core/responsive.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

class WcWallpapersApp extends StatelessWidget {
  const WcWallpapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'WC Wallpapers',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode == ThemeMode.system ? ThemeMode.dark : themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) {
        // Keep system UI in sync with the active brightness.
        final bright = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              bright == Brightness.dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: bright,
          systemNavigationBarColor: bright == Brightness.dark
              ? AppColors.bgPrimary
              : const Color(0xFFF5F0E8),
          systemNavigationBarIconBrightness:
              bright == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: Responsive.clampedTextScaler(context),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgPrimary : const Color(0xFFF5F0E8);
    final surface = isDark ? AppColors.bgCard : const Color(0xFFFFFBF0);
    final onSurface = isDark ? Colors.white : const Color(0xFF2A1F00);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accentGold,
        onPrimary: AppColors.bgPrimary,
        secondary: AppColors.accentOrange,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        background: bg,
        onBackground: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            color: onSurface),
        displayMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            color: onSurface),
        headlineLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: onSurface),
        headlineMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 26,
            color: onSurface),
        titleLarge: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: onSurface),
        titleMedium: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: onSurface),
        bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: isDark ? AppColors.textSecondary : const Color(0xFF664E00)),
        bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: isDark ? AppColors.textSecondary : const Color(0xFF664E00)),
        bodySmall: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF664E00)),
        labelSmall: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: isDark
                ? AppColors.textTertiary
                : const Color(0xFF997500)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeSlideTransitionBuilder(),
          TargetPlatform.iOS: _FadeSlideTransitionBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: onSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      useMaterial3: true,
    );
  }
}

class _FadeSlideTransitionBuilder extends PageTransitionsBuilder {
  const _FadeSlideTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}
