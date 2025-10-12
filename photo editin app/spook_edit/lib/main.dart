import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/editor_provider.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';
import 'views/splash/splash_screen.dart';
import 'views/home/home_screen.dart';
import 'views/style_gallery/style_gallery_screen.dart';
import 'views/processing/processing_screen.dart';
import 'views/result/result_screen.dart';
import 'views/history/history_screen.dart';
import 'views/editor/editor_screen.dart';
import 'views/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0015),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SpookEditApp());
}

class SpookEditApp extends StatelessWidget {
  const SpookEditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
          AppConstants.styleGalleryRoute: (context) => const StyleGalleryScreen(),
          AppConstants.processingRoute: (context) => const ProcessingScreen(),
          AppConstants.resultRoute: (context) => const ResultScreen(),
          AppConstants.historyRoute: (context) => const HistoryScreen(),
          AppConstants.editorRoute: (context) => const EditorScreen(),
          AppConstants.settingsRoute: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
