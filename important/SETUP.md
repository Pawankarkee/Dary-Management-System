# 🚀 Dairify - Setup Guide

This guide will help you set up and run the Dairify application on your machine.

## 📋 Prerequisites

### Required Software

1. **Flutter SDK** (3.0 or higher)
   ```bash
   # Check Flutter installation
   flutter doctor
   ```
   Download from: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (3.0 or higher) - Comes with Flutter

3. **Android Studio** or **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code: https://code.visualstudio.com/

4. **Git**
   ```bash
   git --version
   ```

### Platform-Specific Requirements

#### For Android Development
- Android SDK
- Android Emulator or Physical Device
- Java JDK 11 or higher

#### For iOS Development (macOS only)
- Xcode 13 or higher
- CocoaPods
- iOS Simulator or Physical Device

#### For Web Development
- Chrome, Firefox, or Edge browser

## 🔧 Installation Steps

### 1. Navigate to Project Directory

```bash
cd /home/kc/Desktop/projects/dairy
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will install all required packages listed in `pubspec.yaml`.

### 3. Verify Assets

Ensure the logo.jpg is in the correct location:
```bash
ls -la assets/images/logo.jpg
```

The logo should be at: `assets/images/logo.jpg`

### 4. Run Flutter Doctor

```bash
flutter doctor -v
```

Fix any issues reported by Flutter Doctor before proceeding.

## 🎯 Running the Application

### Option 1: Run on Android

#### Using Emulator
```bash
# List available devices
flutter devices

# Run on Android emulator
flutter run -d android
```

#### Using Physical Device
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run -d <device-id>`

### Option 2: Run on iOS (macOS only)

```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run -d ios
```

### Option 3: Run on Web

```bash
# Run on Chrome
flutter run -d chrome

# Run on specific browser
flutter run -d web-server --web-port=8080
```

### Option 4: Run on Desktop

#### Linux
```bash
flutter run -d linux
```

#### macOS
```bash
flutter run -d macos
```

#### Windows
```bash
flutter run -d windows
```

## 🏗️ Building for Production

### Android APK
```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release

# Then open in Xcode to archive and upload
open ios/Runner.xcworkspace
```

### Web
```bash
flutter build web --release

# Output: build/web/
```

### Desktop
```bash
# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

## 🔐 Configuration

### 1. Configure App Name and Bundle ID

#### Android (`android/app/build.gradle`)
```gradle
defaultConfig {
    applicationId "com.yourcompany.dairify"
    minSdkVersion 21
    targetSdkVersion 33
    versionCode 1
    versionName "1.0.0"
}
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.dairify</string>
```

### 2. Configure App Icon

Place your app icon in:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Or use flutter_launcher_icons package:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.jpg"
```

Then run:
```bash
flutter pub run flutter_launcher_icons
```

### 3. Configure Backend URL

Edit `lib/controllers/sync_controller.dart`:
```dart
await _dio.post('https://your-api-url.com$endpoint', data: payload);
```

Replace `https://your-api-url.com` with your Laravel backend URL.

## 🗄️ Database Setup

The app uses Hive for local storage. No additional database setup is required for the Flutter app.

### Hive Boxes Created:
- `farmers` - Farmer data
- `milk_collections` - Milk collection records
- `transactions` - Financial transactions
- `products` - Product inventory
- `sales` - Sales records
- `sync_queue` - Pending sync items
- `settings` - App settings
- `rate_charts` - Milk rate charts
- `user` - User data

Data is stored locally in:
- Android: `/data/data/com.yourcompany.dairify/app_flutter/`
- iOS: `Library/Application Support/`
- Web: IndexedDB
- Desktop: Application documents folder

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Run in Debug Mode
```bash
flutter run --debug
```

### Run in Profile Mode
```bash
flutter run --profile
```

### Run in Release Mode
```bash
flutter run --release
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 2. "CocoaPods not installed" (iOS)
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

#### 3. "Version solving failed"
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

#### 4. "Hive boxes not found"
```bash
flutter clean
flutter pub get
flutter run
```

#### 5. "Asset not found"
```bash
# Verify asset paths in pubspec.yaml
# Ensure logo.jpg exists in assets/images/
flutter clean
flutter pub get
```

## 📱 First Run Setup

When you first run the app:

1. **Splash Screen** - Shows logo and initializes app
2. **Intro Screens** - 3-slide onboarding (shown only once)
3. **Registration** - Create admin account with PIN
4. **Login** - Use PIN or biometric to login
5. **Home Dashboard** - Main app interface

### Default Test Account
You'll need to create your own account on first run.

## 🔄 Development Workflow

### Hot Reload
Press `r` in terminal while app is running to hot reload changes.

### Hot Restart
Press `R` in terminal to hot restart the app.

### Clear Data
To clear all local data and start fresh:
```bash
# Android
flutter run --clear-cache

# Or manually uninstall and reinstall the app
```

## 📊 Performance Tips

1. **Use `const` widgets** wherever possible
2. **Avoid unnecessary rebuilds** - Use `Consumer` widget wisely
3. **Optimize images** - Use appropriate image sizes
4. **Profile your app** - Use Flutter DevTools

```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 🚀 Deployment

### Google Play Store (Android)

1. Build app bundle:
   ```bash
   flutter build appbundle --release
   ```

2. Sign the app (configure in `android/app/build.gradle`)

3. Upload to Google Play Console

### Apple App Store (iOS)

1. Build iOS app:
   ```bash
   flutter build ios --release
   ```

2. Open in Xcode and archive

3. Upload to App Store Connect

### Web Hosting

1. Build web app:
   ```bash
   flutter build web --release
   ```

2. Deploy `build/web/` to:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages
   - Your own server

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Material Design](https://material.io/design)

## 💡 Tips for Beginners

1. **Start with emulator/simulator** - Easier than physical device
2. **Use hot reload** - See changes instantly
3. **Read error messages** - They're usually helpful
4. **Check Flutter Doctor** - Solves most setup issues
5. **Use VS Code extensions** - Flutter, Dart, etc.

## 🆘 Getting Help

If you encounter issues:

1. Check this setup guide
2. Run `flutter doctor -v`
3. Check Flutter official docs
4. Search on Stack Overflow
5. Open an issue on GitHub

## ✅ Checklist

Before running the app, ensure:

- [ ] Flutter SDK installed (3.0+)
- [ ] `flutter doctor` shows no critical issues
- [ ] Project dependencies installed (`flutter pub get`)
- [ ] Logo file exists at `assets/images/logo.jpg`
- [ ] Device/emulator is connected
- [ ] Android Studio/Xcode configured (if applicable)

## 🎉 Success!

Once everything is set up, you should see:
1. Beautiful animated splash screen with your logo
2. Smooth onboarding experience
3. Login screen with PIN/biometric options
4. Fully functional home dashboard

---

**Happy Coding! 🚀**

For questions or support, please open an issue on GitHub.
