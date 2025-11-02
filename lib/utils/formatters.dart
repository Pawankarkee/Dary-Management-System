import 'package:intl/intl.dart';
import '../config/constants/app_constants.dart';

class AppFormatters {
  // Currency Formatter
  static String currency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(amount);
    return showSymbol ? '${AppConstants.currencySymbol} $formattedAmount' : formattedAmount;
  }

  // Nepali number format (no decimals for quantities)
  static String quantity(double quantity) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(quantity);
  }

  // Integer quantity (for counts)
  static String count(int count) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(count);
  }

  // Date Formatter
  static String date(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.displayDateFormat);
    return formatter.format(date);
  }

  // DateTime Formatter
  static String dateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.displayDateTimeFormat);
    return formatter.format(dateTime);
  }

  // Time Formatter
  static String time(DateTime time) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(time);
  }

  // Percentage Formatter
  static String percentage(double value, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  // FAT/SNF Formatter
  static String fatSnf(double value) {
    return value.toStringAsFixed(2);
  }

  // Phone Number Formatter (Nepal)
  static String phone(String phone) {
    // Remove any non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Format as Nepal phone number
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  // Farmer ID Formatter
  static String farmerId(String id) {
    return 'F${id.padLeft(4, '0')}';
  }

  // Collection ID Formatter
  static String collectionId(String id) {
    return 'C${id.padLeft(6, '0')}';
  }

  // Transaction ID Formatter
  static String transactionId(String id) {
    return 'T${id.padLeft(6, '0')}';
  }
}
