import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/favorites_provider.dart';
import 'providers/wallpaper_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFromPrefs();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF08080F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
      ],
      child: const WcWallpapersApp(),
    ),
  );
}
