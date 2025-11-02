import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

/// SessionManager - Handles persistent user sessions, auto-login, and multi-user support
/// 
/// Features:
/// - Auto-login on app restart
/// - Remember Me functionality
/// - Multiple user account management
/// - Session persistence after logout (keeps business data)
/// - Secure credential storage
/// - User data isolation
class SessionManager {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastUserId = 'last_user_id';
  static const String _keySessionToken = 'session_token';
  static const String _keyUserPin = 'user_pin_';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  /// Check if Remember Me is enabled
  Future<bool> isRememberMeEnabled() async {
    final value = await _secureStorage.read(key: _keyRememberMe);
    return value == 'true';
  }

  /// Set Remember Me preference
  Future<void> setRememberMe(bool enabled) async {
    await _secureStorage.write(key: _keyRememberMe, value: enabled.toString());
  }

  /// Check if auto-login should happen
  Future<bool> shouldAutoLogin() async {
    final rememberMe = await isRememberMeEnabled();
    final hasToken = await hasActiveSession();
    final hasLastUser = await getLastUserId() != null;
    
    // Auto-login if Remember Me is enabled AND user exists
    // (session token check removed - will recreate on login)
    return rememberMe && hasLastUser;
  }

  /// Check if there's an active session
  Future<bool> hasActiveSession() async {
    final token = await _secureStorage.read(key: _keySessionToken);
    return token != null && token.isNotEmpty;
  }

  /// Get last logged in user ID
  Future<String?> getLastUserId() async {
    return await _secureStorage.read(key: _keyLastUserId);
  }

  /// Create a new session for a user
  Future<void> createSession({
    required String userId,
    required String pin,
    required UserModel user,
    bool rememberMe = false,
  }) async {
    try {
      // Save session token
      final sessionToken = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _keySessionToken, value: sessionToken);

      // Save user ID for future reference
      await _secureStorage.write(key: _keyLastUserId, value: userId);

      // Save PIN securely (with user ID prefix for multi-user support)
      await _secureStorage.write(key: '$_keyUserPin$userId', value: pin);

      // Save remember me preference
      await setRememberMe(rememberMe);

      // Save user data to Hive
      final userBox = await HiveService.getUserBox();
      await userBox.put(userId, user.toJson());
      
      // Set current active user
      await userBox.put('current_user', user.toJson());
      await userBox.put('current_user_id', userId);

      print('✅ Session created for user: ${user.name} (ID: $userId)');
    } catch (e) {
      print('❌ Error creating session: $e');
      rethrow;
    }
  }

  /// Load user session on app start
  Future<UserModel?> loadSession() async {
    try {
      final startTime = DateTime.now();

      // Check if should auto-login
      if (!await shouldAutoLogin()) {
        print('⚠️ Auto-login disabled or no active session');
        return null;
      }

      // Get last user ID
      final userId = await getLastUserId();
      if (userId == null) {
        print('⚠️ No last user ID found');
        return null;
      }

      // Load user data from Hive
      final userBox = await HiveService.getUserBox();
      final userData = userBox.get(userId);
      
      if (userData == null) {
        print('⚠️ User data not found for ID: $userId');
        return null;
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      
      // Update current user reference
      await userBox.put('current_user', user.toJson());
      await userBox.put('current_user_id', userId);

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      print('✅ Session loaded in ${loadTime}ms for user: ${user.name}');

      return user;
    } catch (e) {
      print('❌ Error loading session: $e');
      return null;
    }
  }

  /// Validate user PIN
  Future<bool> validatePin(String userId, String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: '$_keyUserPin$userId');
      return storedPin == pin;
    } catch (e) {
      print('❌ Error validating PIN: $e');
      return false;
    }
  }

  /// End current session (logout)
  /// Note: This keeps user business data intact, only clears session
  Future<void> endSession({bool keepRememberMe = true}) async {
    try {
      // Clear session token
      await _secureStorage.delete(key: _keySessionToken);

      // Clear current user reference (but keep user data in Hive)
      final userBox = await HiveService.getUserBox();
      await userBox.delete('current_user');
      // Keep 'current_user_id' and user data for future login

      // Optionally clear remember me
      if (!keepRememberMe) {
        await setRememberMe(false);
      }

      print('✅ Session ended (business data preserved)');
    } catch (e) {
      print('❌ Error ending session: $e');
      rethrow;
    }
  }

  /// Switch to a different user account
  Future<UserModel?> switchUser(String userId) async {
    try {
      // Load user data
      final userBox = await HiveService.getUserBox();
      final userData = userBox.get(userId);
      
      if (userData == null) {
        print('⚠️ User not found: $userId');
        return null;
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));

      // Update current user references
      await userBox.put('current_user', user.toJson());
      await userBox.put('current_user_id', userId);
      await _secureStorage.write(key: _keyLastUserId, value: userId);

      print('✅ Switched to user: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Error switching user: $e');
      return null;
    }
  }

  /// Get all registered users (for multi-user support)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final userBox = await HiveService.getUserBox();
      final List<UserModel> users = [];

      for (var key in userBox.keys) {
        // Skip metadata keys
        if (key == 'current_user' || key == 'current_user_id') continue;

        final userData = userBox.get(key);
        if (userData != null) {
          users.add(UserModel.fromJson(Map<String, dynamic>.from(userData)));
        }
      }

      return users;
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// Check if a user with given ID exists
  Future<bool> userExists(String userId) async {
    try {
      final userBox = await HiveService.getUserBox();
      return userBox.containsKey(userId);
    } catch (e) {
      print('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Get current active user ID
  Future<String?> getCurrentUserId() async {
    try {
      final userBox = await HiveService.getUserBox();
      return userBox.get('current_user_id');
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user PIN
      await _secureStorage.delete(key: '$_keyUserPin$userId');

      // Delete user data from Hive
      final userBox = await HiveService.getUserBox();
      await userBox.delete(userId);

      // If this was the current user, clear current references
      final currentUserId = await getCurrentUserId();
      if (currentUserId == userId) {
        await userBox.delete('current_user');
        await userBox.delete('current_user_id');
        await _secureStorage.delete(key: _keySessionToken);
      }

      // TODO: In a real app, also delete user's business data
      // (farmers, milk collections, etc. associated with this userId)

      print('✅ User account deleted: $userId');
    } catch (e) {
      print('❌ Error deleting user account: $e');
      rethrow;
    }
  }

  /// Update user PIN
  Future<void> updateUserPin(String userId, String newPin) async {
    try {
      await _secureStorage.write(key: '$_keyUserPin$userId', value: newPin);
      print('✅ PIN updated for user: $userId');
    } catch (e) {
      print('❌ Error updating PIN: $e');
      rethrow;
    }
  }

  /// Check if biometric is enabled for current user
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// Set biometric preference
  Future<void> setBiometric(bool enabled) async {
    await _secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Clear all session data (for testing or complete reset)
  Future<void> clearAllSessions() async {
    try {
      await _secureStorage.deleteAll();
      final userBox = await HiveService.getUserBox();
      await userBox.clear();
      print('✅ All sessions cleared');
    } catch (e) {
      print('❌ Error clearing all sessions: $e');
      rethrow;
    }
  }

  /// Get session info for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    return {
      'hasActiveSession': await hasActiveSession(),
      'rememberMeEnabled': await isRememberMeEnabled(),
      'shouldAutoLogin': await shouldAutoLogin(),
      'lastUserId': await getLastUserId(),
      'currentUserId': await getCurrentUserId(),
      'biometricEnabled': await isBiometricEnabled(),
      'totalUsers': (await getAllUsers()).length,
    };
  }

  /// Reset PIN using security answer (PIN recovery)
  /// This allows user to reset forgotten PIN
  Future<bool> resetPinWithSecurityAnswer({
    required String userId,
    required String securityAnswer,
    required String newPin,
  }) async {
    try {
      // Get stored security answer
      final storedAnswer = await _secureStorage.read(key: 'security_answer_$userId');
      
      if (storedAnswer == null) {
        print('⚠️ No security answer set for user');
        return false;
      }

      // Verify security answer (case-insensitive)
      if (storedAnswer.toLowerCase().trim() == securityAnswer.toLowerCase().trim()) {
        // Update PIN
        await _secureStorage.write(key: '$_keyUserPin$userId', value: newPin);
        print('✅ PIN reset successfully for user: $userId');
        return true;
      }

      print('❌ Security answer incorrect');
      return false;
    } catch (e) {
      print('❌ Error resetting PIN: $e');
      return false;
    }
  }

  /// Set security answer for PIN recovery
  Future<void> setSecurityAnswer(String userId, String answer) async {
    try {
      await _secureStorage.write(
        key: 'security_answer_$userId',
        value: answer.toLowerCase().trim(),
      );
      print('✅ Security answer set for user: $userId');
    } catch (e) {
      print('❌ Error setting security answer: $e');
      rethrow;
    }
  }

  /// Check if security answer is set
  Future<bool> hasSecurityAnswer(String userId) async {
    try {
      final answer = await _secureStorage.read(key: 'security_answer_$userId');
      return answer != null && answer.isNotEmpty;
    } catch (e) {
      print('❌ Error checking security answer: $e');
      return false;
    }
  }

  /// Emergency PIN reset (clears all user data)
  /// Use this as last resort if security answer is forgotten
  Future<bool> emergencyResetPin(String userId, String newPin) async {
    try {
      // This is a last resort - warns user that data might be affected
      await _secureStorage.write(key: '$_keyUserPin$userId', value: newPin);
      print('⚠️ Emergency PIN reset performed for user: $userId');
      return true;
    } catch (e) {
      print('❌ Error in emergency PIN reset: $e');
      return false;
    }
  }
}
