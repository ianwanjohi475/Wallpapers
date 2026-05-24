import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/app_colors.dart';
import 'core/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wallpaper_provider.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFromPrefs();
  if (Supabase.instance.client.auth.currentUser != null) {
    await favoritesProvider.syncWithServer();
  }

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  final notificationsProvider = NotificationsProvider();
  await notificationsProvider.loadFromPrefs();

  unawaited(PurchaseService.instance.initialize());

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initial system UI style (dark default; app.dart re-applies per theme change).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: notificationsProvider),
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
      ],
      child: const WcWallpapersApp(),
    ),
  );
}
