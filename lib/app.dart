import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_colors.dart';
import 'core/responsive.dart';
import 'screens/splash_screen.dart';

class WcWallpapersApp extends StatelessWidget {
  const WcWallpapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WC Wallpapers 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentGold,
          secondary: AppColors.accentOrange,
          surface: AppColors.bgCard,
          background: AppColors.bgPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              color: Colors.white),
          displayMedium: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              color: Colors.white),
          headlineLarge: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 34,
              color: Colors.white),
          headlineMedium: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: Colors.white),
          titleLarge: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white),
          titleMedium: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white),
          bodyLarge: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.textSecondary),
          bodyMedium: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.textSecondary),
          bodySmall: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.textSecondary),
          labelSmall: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: AppColors.textTertiary),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeSlideTransitionBuilder(),
            TargetPlatform.iOS: _FadeSlideTransitionBuilder(),
          },
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.bgCard,
          contentTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // Honour accessibility text settings but clamp the extremes so
        // layouts stay intact across every device.
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
