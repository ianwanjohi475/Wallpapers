import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/app_colors.dart';
import 'core/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/wallpaper_provider.dart';

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

  // Show both system bars. Status bar is transparent so hero images flow
  // behind it; nav bar is solid so the gesture/3-button area stays in its
  // own frame outside the app (matching WhatsApp/Instagram behaviour).
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
      ],
      child: const WcWallpapersApp(),
    ),
  );
}
