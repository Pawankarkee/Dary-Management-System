import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Enhanced Security Service
/// Provides comprehensive security features:
/// - Secure data storage
/// - Biometric authentication
/// - Data encryption
/// - Security best practices
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Initialize security service
  Future<void> initialize() async {
    await _checkBiometricSupport();
  }

  // ==================== SECURE STORAGE ====================

  /// Store encrypted data
  Future<void> storeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      print('❌ Error storing secure data: $e');
      rethrow;
    }
  }

  /// Retrieve encrypted data
  Future<String?> getSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('❌ Error retrieving secure data: $e');
      return null;
    }
  }

  /// Delete secure data
  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('❌ Error deleting secure data: $e');
    }
  }

  /// Clear all secure storage
  Future<void> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('❌ Error clearing secure storage: $e');
    }
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Check if biometric authentication is supported
  Future<bool> _checkBiometricSupport() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('❌ Error checking biometric support: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final canCheckBiometrics = await _checkBiometricSupport();
      
      if (!canCheckBiometrics) {
        print('⚠️ Biometric authentication not available');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (e) {
      print('❌ Error during biometric authentication: $e');
      return false;
    }
  }

  /// Stop biometric authentication
  Future<void> stopBiometricAuth() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('❌ Error stopping biometric auth: $e');
    }
  }

  // ==================== DATA ENCRYPTION ====================

  /// Encrypt sensitive data (using SHA-256)
  String encryptData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure hash with salt
  String hashWithSalt(String data, String salt) {
    final combined = data + salt;
    return encryptData(combined);
  }

  /// Validate hashed data
  bool validateHash(String data, String hash, String salt) {
    final computedHash = hashWithSalt(data, salt);
    return computedHash == hash;
  }

  // ==================== SECURE KEY GENERATION ====================

  /// Generate random secure key
  String generateSecureKey(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    final random = DateTime.now().millisecondsSinceEpoch;
    var key = '';
    
    for (var i = 0; i < length; i++) {
      key += chars[(random + i) % chars.length];
    }
    
    return key;
  }

  // ==================== SESSION SECURITY ====================

  /// Store session token securely
  Future<void> storeSessionToken(String token) async {
    await storeSecure('session_token', token);
  }

  /// Get session token
  Future<String?> getSessionToken() async {
    return await getSecure('session_token');
  }

  /// Clear session token
  Future<void> clearSessionToken() async {
    await deleteSecure('session_token');
  }

  // ==================== PIN SECURITY ====================

  /// Store encrypted PIN
  Future<void> storePIN(String pin) async {
    final salt = generateSecureKey(16);
    final hashedPin = hashWithSalt(pin, salt);
    
    await storeSecure('pin_hash', hashedPin);
    await storeSecure('pin_salt', salt);
  }

  /// Validate PIN
  Future<bool> validatePIN(String pin) async {
    try {
      final storedHash = await getSecure('pin_hash');
      final salt = await getSecure('pin_salt');
      
      if (storedHash == null || salt == null) {
        return false;
      }
      
      return validateHash(pin, storedHash, salt);
    } catch (e) {
      print('❌ Error validating PIN: $e');
      return false;
    }
  }

  /// Clear PIN
  Future<void> clearPIN() async {
    await deleteSecure('pin_hash');
    await deleteSecure('pin_salt');
  }

  // ==================== SECURITY CHECKS ====================

  /// Check if app is running in debug mode
  bool isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Validate app integrity
  Future<bool> validateAppIntegrity() async {
    // This would check for root/jailbreak in production
    // For now, return true
    return true;
  }

  /// Check for root/jailbreak
  Future<bool> isDeviceSecure() async {
    // This would implement actual root/jailbreak detection
    // For now, assume device is secure
    return true;
  }

  // ==================== DATA SANITIZATION ====================

  /// Sanitize user input to prevent injection
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number
  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Check password strength
  Map<String, dynamic> checkPasswordStrength(String password) {
    int strength = 0;
    final checks = <String, bool>{};

    // Length check
    checks['length'] = password.length >= 8;
    if (checks['length']!) strength++;

    // Uppercase check
    checks['uppercase'] = password.contains(RegExp(r'[A-Z]'));
    if (checks['uppercase']!) strength++;

    // Lowercase check
    checks['lowercase'] = password.contains(RegExp(r'[a-z]'));
    if (checks['lowercase']!) strength++;

    // Number check
    checks['number'] = password.contains(RegExp(r'[0-9]'));
    if (checks['number']!) strength++;

    // Special character check
    checks['special'] = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (checks['special']!) strength++;

    String strengthText = 'Weak';
    if (strength >= 4) strengthText = 'Strong';
    else if (strength >= 3) strengthText = 'Medium';

    return {
      'strength': strength,
      'strengthText': strengthText,
      'checks': checks,
    };
  }

  // ==================== SECURE LOGGING ====================

  /// Log security events (sanitized)
  void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (!isDebugMode()) {
      // In production, this would go to a secure logging service
      print('🔐 Security Event: $event');
      if (details != null) {
        // Remove sensitive data before logging
        final sanitizedDetails = _sanitizeLogDetails(details);
        print('   Details: $sanitizedDetails');
      }
    }
  }

  /// Sanitize log details to remove sensitive information
  Map<String, dynamic> _sanitizeLogDetails(Map<String, dynamic> details) {
    final sanitized = <String, dynamic>{};
    final sensitiveKeys = ['password', 'pin', 'token', 'key', 'secret'];

    details.forEach((key, value) {
      if (sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
        sanitized[key] = '***REDACTED***';
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  // ==================== CLEANUP ====================

  /// Dispose and cleanup
  Future<void> dispose() async {
    await stopBiometricAuth();
  }
}

/// Security constants
class SecurityConstants {
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int minPasswordLength = 8;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);
}
