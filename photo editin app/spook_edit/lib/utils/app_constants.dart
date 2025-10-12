import 'package:flutter/material.dart';

/// App-wide constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'SpookEdit';
  static const String appTagline = 'Hauntingly Beautiful Edits';
  static const String version = '1.0.0';

  // API Configuration
  // Using proxy server - no API key needed in Flutter app
  static String get falApiKey => 'proxy'; // Dummy value, proxy handles auth

  // Proxy server always has API key configured
  static bool get isFalApiKeyConfigured => true;

  // Get user-friendly API key status message
  static String get apiKeyStatusMessage => 'Using proxy server for API calls';

  // Routes
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String styleGalleryRoute = '/style-gallery';
  static const String processingRoute = '/processing';
  static const String resultRoute = '/result';
  static const String historyRoute = '/history';
  static const String editorRoute = '/editor';
  static const String settingsRoute = '/settings';
  static const String framesRoute = '/frames';
  static const String collageRoute = '/collage';
  static const String promptBrowserRoute = '/prompts';
  static const String nanobanaTestRoute = '/nanobana-test';

  // Halloween Theme Colors - Enhanced Palette
  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF6600);
  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color darkPurple = Color(0xFF1A0033);
  static const Color mediumPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFF9333EA);

  // Accent Colors
  static const Color bloodRed = Color(0xFF8B0000);
  static const Color bloodOrange = Color(0xFFFF4500);
  static const Color pumpkinOrange = Color(0xFFFF7518);
  static const Color brightOrange = Color(0xFFFF6B35);
  static const Color candyCornYellow = Color(0xFFFFB700);

  // Supporting Colors
  static const Color ghostWhite = Color(0xFFF8F8FF);
  static const Color midnightBlack = Color(0xFF0A0A0A);
  static const Color witchGreen = Color(0xFF228B22);
  static const Color zombieGreen = Color(0xFF4ADE80);
  static const Color vampireRed = Color(0xFFDC2626);

  // Image Settings
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const int thumbnailSize = 200;
  static const int jpegQuality = 90;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Sticker Categories
  static const List<String> stickerCategories = [
    'Creatures',
    'Pumpkins',
    'Text Bubbles',
    'Props',
    'Effects',
  ];

  // Max Undo/Redo Stack
  static const int maxUndoStack = 20;

  // Permissions
  static const String cameraPermission = 'camera';
  static const String storagePermission = 'storage';
  static const String photosPermission = 'photos';
}

/// Halloween-themed gradient presets
class HalloweenGradients {
  static const LinearGradient spookyNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppConstants.darkPurple,
      Color(0xFF2E0854),
      AppConstants.primaryOrange,
    ],
  );

  static const LinearGradient vampireBlood = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0000),
      AppConstants.bloodRed,
      Color(0xFF4A0000),
    ],
  );

  static const LinearGradient witchPotion = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppConstants.primaryPurple,
      AppConstants.witchGreen,
      Color(0xFF004D00),
    ],
  );

  static const LinearGradient pumpkinGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF4500),
      AppConstants.pumpkinOrange,
      Color(0xFFFFB347),
    ],
  );
}

/// Asset paths
class AssetPaths {
  static const String images = 'assets/images/';
  static const String stickers = 'assets/stickers/';
  static const String frames = 'assets/frames/';
  static const String backgrounds = 'assets/backgrounds/';
  static const String animations = 'assets/animations/';
  static const String sounds = 'assets/sounds/';

  // Placeholder assets
  static const String logoPlaceholder = '${images}logo.png';
  static const String splashAnimation = '${animations}splash.json';
}

/// Halloween fonts
class HalloweenFonts {
  static const String creepster = 'Creepster';
  static const String nosifer = 'Nosifer';
  static const String butcherman = 'Butcherman';
  static const String eater = 'Eater';
  static const String bloodyCursive = 'Jolly Lodger';
}
