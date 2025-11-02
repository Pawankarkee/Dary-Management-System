# 🥛 Dairify - Complete Dairy Management System

![Dairify Logo](assets/images/logo.jpg)

**Dairify** is a comprehensive, offline-first dairy management system designed for dairy shop owners who collect milk from farmers and sell cattle products. Built with Flutter for cross-platform support and Laravel for backend services.

## ✨ Key Features

### 🔐 **Offline-First Architecture**
- Works seamlessly without internet connection
- All operations save immediately to local Hive database
- Automatic sync when internet is available
- Manual "Sync Now" button for forced synchronization
- No data loss guarantee

### 👥 **User Management**
- **Admin Role**: Full system access
- **Collector Role**: Limited access (milk collection only)
- PIN-based authentication
- Biometric login support (fingerprint/face)
- Auto-logout after 30 minutes of inactivity

### 🌾 **Farmer Management**
- Auto-generated unique Farmer IDs (F001, F002, F003...)
- Comprehensive farmer profiles with photo upload
- Village-wise organization
- Running balance tracking
- Search and filter functionality
- Soft delete (deactivation)

### 🥛 **Milk Collection System**
- Quick entry form with auto-calculation
- FAT and SNF percentage tracking
- Shift-based collection (Morning/Evening)
- Rate calculation based on FAT/SNF ranges
- Duplicate entry prevention
- Real-time totals and summaries
- Collection slips generation

### 💰 **Advance & Credit (Audharo) System**
- Bidirectional money flow tracking
- Auto-adjustment from milk payments
- Multiple transaction types:
  - Milk Payment (+)
  - Advance (+)
  - Credit (-)
  - Product Purchase (-)
  - Settlement (-)
- Complete transaction history

### 📦 **Product/Stock Management** (Optional)
- Product catalog with categories
- Stock in/out tracking
- Low stock alerts
- Expiry date warnings
- Sale entry with auto-stock deduction
- Multiple payment types support

### 📊 **Reports & Analytics**
- Milk collection reports
- Farmer ledger statements
- Advance/credit reports
- Stock reports
- Profit summary
- PDF/Excel export

### 🎨 **Modern UI/UX**
- Beautiful, responsive design
- Dark mode and light mode support
- Top navigation bar
- Adaptive layouts for mobile, tablet, and desktop
- Material Design 3
- Smooth animations and transitions

## 🏗️ Technical Stack

### **Frontend**
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: Hive
- **UI Components**: Material Design 3

### **Backend** (To be implemented)
- **Framework**: Laravel
- **Database**: PostgreSQL
- **Architecture**: MVC
- **API**: RESTful

## 📱 Screenshots

### Splash Screen & Onboarding
- Animated splash screen with logo
- 3-slide onboarding flow
- Beautiful gradient backgrounds

### Authentication
- PIN-based login
- Biometric authentication
- User registration

### Dashboard
- Today's summary cards
- Quick action buttons
- Alert notifications
- Real-time sync status

## 🚀 Getting Started

### Prerequisites
```bash
# Flutter SDK (3.0+)
flutter --version

# Dart SDK (3.0+)
dart --version
```

### Installation

1. **Clone the repository**
```bash
cd /home/kc/Desktop/projects/dairy
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   ├── theme/
│   │   └── app_theme.dart      # Theme configuration
│   └── routes/
│       └── app_router.dart     # Route management
├── models/
│   ├── user_model.dart         # User data model
│   ├── farmer_model.dart       # Farmer data model
│   ├── milk_collection_model.dart
│   ├── transaction_model.dart
│   └── product_model.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── theme_controller.dart
│   ├── farmer_controller.dart
│   ├── milk_controller.dart
│   ├── transaction_controller.dart
│   ├── product_controller.dart
│   └── sync_controller.dart
├── services/
│   └── hive_service.dart       # Local database service
├── views/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── intro_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── farmers/
│   │   ├── milk/
│   │   ├── products/
│   │   ├── reports/
│   │   └── settings/
│   └── layouts/
│       └── main_layout.dart    # Main app layout
└── assets/
    └── images/
        └── logo.jpg           # App logo
```

## 🎯 Core Functionality

### MVC Architecture

**Models**: Define data structures (Farmer, Milk Collection, Transaction, Product)
**Views**: UI screens and widgets
**Controllers**: Business logic and state management using Provider

### Offline-First Implementation

```dart
// 1. User performs action → Save to Hive (local)
await HiveService.getFarmersBox().put(farmer.id, farmer.toJson());

// 2. Queue for sync
await syncController.queueForSync(
  type: 'farmer',
  action: 'create',
  referenceId: farmer.id,
);

// 3. Auto-sync when online
if (isOnline && hasPendingSync) {
  await syncController.syncNow();
}
```

### Rate Calculation Formula

```dart
Rate = Base Rate + (FAT × FAT Multiplier) + (SNF × SNF Multiplier)
Example: ₹20 + (6.0% × ₹2.5) + (8.5% × ₹1.5) = ₹47.75/liter
```

### Auto-Adjustment Logic

```dart
// When milk is collected, check farmer's credit balance
if (farmer.runningBalance < 0) {
  // Auto-deduct credit from milk payment
  netPayment = milkPayment - abs(creditBalance);
}
```

## 🔧 Configuration

### Theme Customization

Edit `lib/config/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF2196F3); // Blue
static const Color secondaryColor = Color(0xFF4CAF50); // Green
static const Color accentColor = Color(0xFFFF9800); // Orange
```

### Responsive Breakpoints

```dart
static const double mobileBreakpoint = 600;
static const double tabletBreakpoint = 900;
static const double desktopBreakpoint = 1200;
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  hive: ^2.2.3                  # Local database
  hive_flutter: ^1.1.0
  dio: ^5.4.0                   # HTTP client
  connectivity_plus: ^5.0.2     # Network status
  flutter_secure_storage: ^9.0.0 # Secure storage
  local_auth: ^2.1.8            # Biometric auth
  image_picker: ^1.0.7          # Photo capture
  intl: ^0.19.0                 # Internationalization
  uuid: ^4.3.3                  # ID generation
  pdf: ^3.10.8                  # PDF generation
  printing: ^5.12.0             # Printing
  excel: ^4.0.2                 # Excel export
  fl_chart: ^0.66.0             # Charts
  google_fonts: ^6.1.0          # Custom fonts
```

## 🔐 Security Features

- Encrypted local storage using Hive
- Secure PIN storage with flutter_secure_storage
- Biometric authentication
- Role-based access control
- Auto-logout after inactivity
- Audit trail logging

## 📱 Platform Support

- ✅ Android (SDK 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Windows (Desktop)
- ✅ macOS (Desktop)
- ✅ Linux (Desktop)

## 🎨 Design Specifications

### Color Scheme
- **Primary**: Blue (#2196F3) - Trust, reliability
- **Secondary**: Green (#4CAF50) - Freshness, growth
- **Accent**: Orange (#FF9800) - Energy, warmth

### Typography
- **Font Family**: Poppins (clean, modern, readable)
- **Font Sizes**: 12px to 32px (responsive)
- **Font Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Spacing
- Consistent 4px, 8px, 12px, 16px, 20px, 24px, 32px, 48px grid

### Border Radius
- Small: 8px
- Medium: 12px
- Large: 16px
- XLarge: 24px

## 🚧 Roadmap

### Phase 1: Core MVP ✅ (Current)
- [x] Project structure setup
- [x] Authentication system
- [x] Theme system (dark/light mode)
- [x] Splash & intro screens
- [x] Main layout with navigation
- [x] Home dashboard
- [x] Hive local database setup
- [x] Models and controllers
- [x] Sync controller foundation

### Phase 2: Feature Implementation 🚧 (In Progress)
- [ ] Complete farmer management screens
- [ ] Complete milk collection screens
- [ ] Transaction/ledger screens
- [ ] Product management screens
- [ ] Reports generation
- [ ] PDF/Excel export
- [ ] Print functionality

### Phase 3: Backend & Sync 📋 (Planned)
- [ ] Laravel backend setup
- [ ] PostgreSQL database
- [ ] RESTful API endpoints
- [ ] JWT authentication
- [ ] Sync implementation
- [ ] Conflict resolution

### Phase 4: Polish & Deploy 📋 (Planned)
- [ ] Performance optimization
- [ ] Security hardening
- [ ] User testing
- [ ] Bug fixes
- [ ] Documentation
- [ ] Play Store/App Store deployment

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- All open-source contributors

## 📞 Support

For support, email your.email@example.com or open an issue on GitHub.

---

**Made with ❤️ for dairy farmers and shop owners**
