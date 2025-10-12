# 🎃 SpookEdit - Halloween Photo Editor

SpookEdit is a comprehensive Flutter-based Halloween photo editor powered by AI (Nano Banana via fal.ai). Create hauntingly beautiful images with AI-powered filters, backgrounds, and effects.

![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart) ![AI](https://img.shields.io/badge/AI-Nano%20Banana-FF6B6B)

## ✨ Features

### 🎨 AI-Powered Editing
- **8 Halloween Filters**: Spooky Night, Vampire, Zombie, Ghost, Pumpkin Glow, Haunted, Blood Moon, Witch Hour
- **Background Generation**: Haunted House, Cemetery, Dark Forest, Full Moon, Abandoned Mansion, Pumpkin Patch
- **Natural Language Editing**: Powered by Nano Banana AI from fal.ai

### 📸 Image Management
- **Gallery Integration**: Select photos from your device
- **Camera Support**: Capture photos directly in-app
- **Undo/Redo**: Full editing history with up to 20 steps
- **Save & Share**: Export to gallery or share to social media

### 🛠️ Professional Tools
- **Adjustments**: Brightness, Contrast, Saturation, Spookiness
- **Interactive Viewer**: Zoom and pan your photos
- **Real-time Preview**: See changes instantly

### 🎭 Halloween Theme
- Custom UI with spooky gradients and animations
- Halloween-inspired color scheme (Orange, Purple, Red)
- Creepy fonts (Google Fonts: Creepster)
- Floating ghost particle animations

## 🚀 Getting Started

### Prerequisites
- Flutter 3.29.0 or higher
- Dart 3.7.0 or higher
- iOS 12.0+ / Android SDK 21+
- A fal.ai API key ([get one here](https://fal.ai/dashboard))

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure API Key**

   Create a `.env` file in the project root:
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your fal.ai API key:
   ```
   FAL_API_KEY=your_actual_api_key_here
   ```

   ⚠️ **Important**: Never commit your `.env` file to version control!

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### iOS
Add these permissions to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to edit them</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save edited photos</string>
```

#### Android
Permissions are already configured in `android/app/src/main/AndroidManifest.xml`

## 📁 Project Structure

```
spook_edit/
├── lib/
│   ├── models/              # Data models
│   ├── providers/           # State management (Provider)
│   ├── services/            # API services (Nano Banana)
│   ├── utils/               # Constants & themes
│   ├── views/               # UI screens
│   ├── widgets/             # Reusable widgets
│   └── main.dart
├── assets/                  # Images, fonts, etc.
└── .env                     # Environment variables (not committed)
```

## 🎃 Halloween Filters

| Filter | Description |
|--------|-------------|
| **Spooky Night** | Dark blue/purple tones with eerie moonlight |
| **Vampire** | Pale skin, red eyes, gothic atmosphere |
| **Zombie** | Green tint, decay texture, horror vibes |
| **Ghost** | Ethereal transparency with ghostly glow |
| **Pumpkin Glow** | Warm orange tones, autumn atmosphere |
| **Haunted** | Vintage sepia with aged photo effect |
| **Blood Moon** | Deep red atmospheric lighting |
| **Witch Hour** | Purple-green mystical effect |

## 📱 Screens

1. **Splash Screen**: Animated intro with floating ghost particles
2. **Home Screen**: Gallery/Camera access with Halloween theme
3. **Editor Screen**: Main editing interface with filters and tools
4. **Settings Screen**: App configuration and information

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Release

**iOS**:
```bash
flutter build ios --release
```

**Android**:
```bash
flutter build apk --release
```

## 📦 Key Dependencies

- `provider`: State management
- `http`: API communication
- `image_picker`: Gallery/camera access
- `photo_view`: Interactive image viewer
- `google_fonts`: Custom fonts
- `flutter_dotenv`: Environment variables
- `image_gallery_saver`: Save to gallery
- `share_plus`: Share functionality

See `pubspec.yaml` for complete list.

## 🔐 Security

- API keys stored in `.env` (not committed)
- Permissions requested at runtime
- Secure image handling

## 🚧 Future Enhancements

- [ ] Sticker system
- [ ] Face detection
- [ ] Collage maker
- [ ] Animation creator
- [ ] Custom frames
- [ ] AR effects

## 📄 License

This project is for educational/personal use. Please respect fal.ai's terms of service.

---

**Made with 🎃 and Flutter**
