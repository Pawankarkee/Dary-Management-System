import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// Mobile: < 768px
/// Tablet: 768px - 1023px
/// Desktop: >= 1024px
class Responsive {
  // Device type detection
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Responsive text sizes
  static double heading1(BuildContext context) =>
      isMobile(context) ? 24.0 : 32.0;

  static double heading2(BuildContext context) =>
      isMobile(context) ? 20.0 : 24.0;

  static double heading3(BuildContext context) =>
      isMobile(context) ? 18.0 : 20.0;

  static double bodyLarge(BuildContext context) =>
      isMobile(context) ? 16.0 : 18.0;

  static double bodyMedium(BuildContext context) =>
      isMobile(context) ? 14.0 : 16.0;

  static double bodySmall(BuildContext context) =>
      isMobile(context) ? 12.0 : 14.0;

  static double caption(BuildContext context) =>
      isMobile(context) ? 11.0 : 13.0;

  // Responsive spacing
  static double spacingXS(BuildContext context) =>
      isMobile(context) ? 4.0 : 6.0;

  static double spacingS(BuildContext context) =>
      isMobile(context) ? 8.0 : 12.0;

  static double spacingM(BuildContext context) =>
      isMobile(context) ? 12.0 : 16.0;

  static double spacingL(BuildContext context) =>
      isMobile(context) ? 16.0 : 24.0;

  static double spacingXL(BuildContext context) =>
      isMobile(context) ? 24.0 : 32.0;

  // Responsive padding
  static EdgeInsets paddingAll(BuildContext context) =>
      EdgeInsets.all(isMobile(context) ? 16.0 : 24.0);

  static EdgeInsets paddingHorizontal(BuildContext context) =>
      EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 16.0 : 24.0);

  static EdgeInsets paddingVertical(BuildContext context) =>
      EdgeInsets.symmetric(vertical: isMobile(context) ? 16.0 : 24.0);

  // Responsive field height
  static double fieldHeight(BuildContext context) =>
      isMobile(context) ? 56.0 : 48.0; // Larger on mobile for touch

  // Responsive button height
  static double buttonHeight(BuildContext context) =>
      isMobile(context) ? 48.0 : 44.0;

  // Minimum touch target size (mobile)
  static double minTouchTarget(BuildContext context) =>
      isMobile(context) ? 48.0 : 44.0;

  // Card padding
  static EdgeInsets cardPadding(BuildContext context) => EdgeInsets.all(
      isMobile(context) ? 12.0 : 16.0);

  // Screen horizontal padding
  static EdgeInsets screenPadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: isMobile(context) ? 16.0 : (isTablet(context) ? 24.0 : 32.0),
        vertical: isMobile(context) ? 16.0 : 24.0,
      );

  // Icon size
  static double iconSize(BuildContext context) =>
      isMobile(context) ? 24.0 : 20.0;

  // Max content width for desktop
  static double maxContentWidth(BuildContext context) =>
      isDesktop(context) ? 1200.0 : double.infinity;

  // Grid columns based on screen size
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Get value based on device type
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

/// Mobile-specific size constants (consolidated from mobile_sizes.dart)
class MobileSizes {
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;

  // Text sizes
  static const double screenTitle = 18.0;
  static const double sectionTitle = 16.0;
  static const double heading = 14.0;
  static const double bodyLarge = 14.0;
  static const double bodyMedium = 13.0;
  static const double bodySmall = 12.0;
  static const double caption = 11.0;
  static const double label = 14.0;
  static const double cardTitle = 15.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXL = 32.0;
  static const double iconAppBar = 22.0;

  // Button sizes
  static const double buttonHeight = 42.0;
  static const double buttonRadius = 8.0;

  // Card sizes
  static const double cardRadius = 10.0;
  static const double cardElevation = 2.0;
  static const double cardPadding = 12.0;

  // Input field
  static const double inputRadius = 8.0;
  static const double inputHeight = 44.0;
  static const double fieldPaddingH = 16.0;
  static const double fieldPaddingV = 12.0;
  static const double borderRadius = 8.0;

  // Avatar
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  
  // Device detection helper
  static bool isMobile(double width) => width < 768;
  static bool isTablet(double width) => width >= 768 && width < 1024;
  static bool isDesktop(double width) => width >= 1024;
}

