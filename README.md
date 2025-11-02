# Dairy Management System

>A lightweight, offline-first mobile & web application for small dairy collection centers. Built with Flutter, Hive for local persistence, and designed for collectors/admins to manage farmers, milk collections, payments, and simple sync workflows.

---

## Quick links
- Repository: https://github.com/Pawankarkee/Dary-Management-System

## Overview
This project provides a complete app for dairy collection operations including:
- Farmer management (profiles, photos)
- Milk collection records
- Products, purchases and sales
- Basic reporting and summaries (Today, Collections)
- Local persistence with Hive (encrypted user box)
- Offline-capable mock sync (in-app mock server to simulate push/pull)
- Biometric login (optional) and PIN fallback

The app is tailored to run on Android, iOS and web (Flutter web) with most features available offline.

## Features (implemented)
- Farmer CRUD (add/edit/delete) with local photo persistence
- Milk collection recording and listing
- Local mock sync service to simulate server push/pull (useful when no real server available)
- Bottom navigation and main layout with responsive UI
- Settings screen: backup, biometric toggle, fetch from mock server
- Native branding: custom splash and launcher icons
- Biometric-based auto-login on app start (uses local_auth)

## Coming soon (planned enhancements)
- Real remote sync server adapter (HTTP API) and conflict resolution UI
- Two-device end-to-end sync test harness (or tiny hosted mock server)
- Role-based access (admin vs collector) with permissions
- Improved reporting & export (CSV/PDF)
- Automated CI build pipeline (GitHub Actions) which publishes APK/AAB on release
- More unit and widget tests

## Prerequisites
- Flutter SDK (tested with Flutter 3.x+; use latest stable recommended)
- Android SDK & platform-tools (for Android builds)
- Xcode (for iOS builds on macOS)
- A device or emulator for testing (Android recommended for full native flows)

## Install & run (developer / local)
1. Clone the repo:

```bash
git clone https://github.com/Pawankarkee/Dary-Management-System.git
cd Dary-Management-System
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run on an Android device (debug):

```bash
flutter run -d <device-id>
```

4. Build release APKs (universal):

```bash
flutter build apk --release
# artifact: build/app/outputs/apk/release/app-release.apk
```

To produce ABI-split apks (arm & arm64):

```bash
flutter build apk --split-per-abi --release
# artifacts: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk etc.
```

5. Build Android App Bundle (for Play Store):

```bash
flutter build appbundle --release
# artifact: build/app/outputs/bundle/release/app-release.aab
```

## How to use (app flow)
1. Authentication
   - On first launch you'll be guided through PIN setup or login.
   - Settings allow enabling biometric login. When enabled, the Splash screen will try biometric authentication and route to the main app on success.

2. Farmers
   - Add a farmer using "Add Farmer" screen.
   - Upload/take a photo: the image is copied into the app documents directory and its path is saved to the farmer record.
   - Edit or view a farmer's profile via the Farmer Detail screen.

3. Milk Collections
   - Record daily collections using the Add Milk screen.
   - Collections are stored locally in Hive and included in reports.

4. Sync
   - If you don't have a real server, use the in-app Mock Server (Settings -> Fetch from mock server) to simulate remote pushes/pulls.
   - The SyncController queues local changes and will push to the configured remote or mock server depending on settings.

5. Backup & Restore
   - Use Settings -> Backup to export local data; use Restore (if implemented) to import.

## Developer notes & architecture
- State management: simple ChangeNotifier controllers (lib/controllers)
- Local persistence: Hive (lib/services/hive_service.dart)
- Mock server: lib/services/mock_server_service.dart — stores server-like records in local Hive boxes named `server_<type>` and encodes images in base64.
- Authentication: lib/controllers/auth_controller.dart, SessionManager for PIN/biometric preference storage
- Routing: lib/config/routes/app_router.dart

## Contributing
1. Fork the repo on GitHub
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes and commit with clear messages
4. Push to your fork and open a Pull Request

Please include unit or widget tests for new features when possible.

## License
This project is provided with an MIT-style license. Include a LICENSE file if you want a formal license in the repo.

## Contact
Project owner: PawanKarkee
Email: bholavai.50@gmail.com

---

If you want, I can also:
- Create a `README.md` (this file) in the repo (done now),
- Add a `LICENSE` (MIT) and `CONTRIBUTING.md`,
- Set up a simple GitHub Actions workflow to build APKs on push to `main`, and
- Create a GitHub Release with the built APK attached.

Tell me which of those extras you want next.
