class AppConstants {
  // App Info
  static const String appName = 'Dairify';
  static const String appVersion = '1.0.0';
  
  // Currency
  static const String currencySymbol = 'Rs'; // Standard Rupee symbol for Nepal
  static const String RUPEE_SYMBOL = '₨'; // Alternate rupee glyph for compatibility
  static const String currencyCode = 'NPR';
  static const String currencyName = 'Nepali Rupee';
  
  // Date Format
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  
  // Milk Collection
  static const double defaultFatRate = 2.5;
  static const double defaultSnfRate = 1.5;
  static const double defaultBaseRate = 45.0; // Base rate per liter in NPR
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image
  static const double maxImageSizeMB = 5.0;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  
  // Sync
  static const int syncIntervalMinutes = 30;
  static const int maxSyncRetries = 3;
  
  // Reports
  static const String pdfAuthor = 'Dairify';
  static const String excelAuthor = 'Dairify';

  // Currency Formatters
  static String formatCurrency(double amount) {
  return '$currencySymbol ${amount.toStringAsFixed(2)}';
  }

  static String formatRate(double rate) {
  return '$currencySymbol ${rate.toStringAsFixed(2)}/L';
  }

  static String formatAmount(double amount, {int decimals = 2}) {
  return '$currencySymbol ${amount.toStringAsFixed(decimals)}';
  }
}
