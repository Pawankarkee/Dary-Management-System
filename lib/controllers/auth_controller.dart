import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/session_manager.dart';

class AuthController extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SessionManager _sessionManager = SessionManager();

  bool _isAuthenticated = false;
  bool _isFirstTime = true;
  UserModel? _currentUser;
  bool _isBiometricEnabled = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstTime => _isFirstTime;
  UserModel? get currentUser => _currentUser;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;

  // Check authentication status (with auto-login support)
  Future<void> checkAuthentication() async {
    try {
      _isLoading = true;
      notifyListeners();

      final introCompleted = await _secureStorage.read(key: 'intro_completed');
      _isFirstTime = introCompleted != 'true';

      // Check if remember me is enabled
      _rememberMe = await _sessionManager.isRememberMeEnabled();

      // Load biometric preference
      _isBiometricEnabled = await _sessionManager.isBiometricEnabled();

      // Try to load existing session (auto-login)
      if (await _sessionManager.shouldAutoLogin()) {
        _currentUser = await _sessionManager.loadSession();
        _isAuthenticated = _currentUser != null;
        
        if (_isAuthenticated) {
          print('✅ Auto-login successful for: ${_currentUser!.name}');
        }
      } else {
        // Check for active session without auto-login
        final hasSession = await _sessionManager.hasActiveSession();
        if (hasSession) {
          await _loadCurrentUser();
          _isAuthenticated = _currentUser != null;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error checking authentication: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete intro
  Future<void> completeIntro() async {
    await _secureStorage.write(key: 'intro_completed', value: 'true');
    _isFirstTime = false;
    notifyListeners();
  }

  // Login with PIN (with remember me support)
  Future<bool> loginWithPin(String pin, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get last user ID or try to find user by PIN
      String? userId = await _sessionManager.getLastUserId();
      
      if (userId == null) {
        // First time login, try to find user
        userId = await _findUserByPin(pin);
      }

      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate PIN
      final isValid = await _sessionManager.validatePin(userId, pin);
      
      if (!isValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Load user data
      await _loadCurrentUser();
      
      if (_currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create session
      await _sessionManager.createSession(
        userId: userId,
        pin: pin,
        user: _currentUser!,
        rememberMe: rememberMe,
      );

      _isAuthenticated = true;
      _rememberMe = rememberMe;
      _isLoading = false;
      notifyListeners();
      
      print('✅ Login successful for: ${_currentUser!.name}');
      return true;
    } catch (e) {
      print('❌ Error logging in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Find user by PIN (helper method)
  Future<String?> _findUserByPin(String pin) async {
    try {
      final users = await _sessionManager.getAllUsers();
      for (var user in users) {
        if (await _sessionManager.validatePin(user.id, pin)) {
          return user.id;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error finding user by PIN: $e');
      return null;
    }
  }

  // Login with biometric (with remember me support)
  Future<bool> loginWithBiometric({bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Dairify',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        // Load last user
        await _loadCurrentUser();
        
        if (_currentUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Get stored PIN for session creation
        final userId = _currentUser!.id;
        
        // Create session (we don't have PIN here, so use a dummy value)
        // In real app, you might store biometric token differently
        await _sessionManager.createSession(
          userId: userId,
          pin: '', // Empty for biometric login
          user: _currentUser!,
          rememberMe: rememberMe,
        );

        _isAuthenticated = true;
        _rememberMe = rememberMe;
        _isLoading = false;
        notifyListeners();
        
        print('✅ Biometric login successful for: ${_currentUser!.name}');
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error with biometric authentication: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with staff credentials (username and password)
  Future<bool> loginAsStaff(String username, String password, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Import StaffController dynamically to avoid circular dependency
      // Note: In production, you might want to pass StaffController as a parameter
      // or use a better architecture pattern
      
      _isLoading = false;
      notifyListeners();
      
      // Return false for now - this needs to be implemented with proper architecture
      // The calling code should handle staff validation
      return false;
    } catch (e) {
      print('❌ Error with staff login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user (with auto-session creation)
  Future<bool> register({
    required String name,
    required String pin,
    required UserRole role,
    bool rememberMe = true,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      // Create session with SessionManager
      await _sessionManager.createSession(
        userId: user.id,
        pin: pin,
        user: user,
        rememberMe: rememberMe,
      );

      _currentUser = user;
      _isAuthenticated = true;
      _rememberMe = rememberMe;
      _isLoading = false;
      notifyListeners();
      
      print('✅ User registered: ${user.name}');
      return true;
    } catch (e) {
      print('❌ Error registering user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    try {
      final box = await HiveService.getUserBox();
      final userData = box.get('current_user');
      
      if (userData != null) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(userData));
      } else {
        // Try loading from session manager
        _currentUser = await _sessionManager.loadSession();
      }
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  // Check if biometric is available
  Future<bool> checkBiometricAvailability() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Enable/Disable biometric
  Future<void> setBiometric(bool enabled) async {
    _isBiometricEnabled = enabled;
    await _sessionManager.setBiometric(enabled);
    notifyListeners();
  }

  // Set remember me preference
  Future<void> setRememberMe(bool enabled) async {
    _rememberMe = enabled;
    await _sessionManager.setRememberMe(enabled);
    notifyListeners();
  }

  // Logout (keeps business data, only clears session)
  Future<void> logout({bool keepRememberMe = true}) async {
    try {
      await _sessionManager.endSession(keepRememberMe: keepRememberMe);
      _isAuthenticated = false;
      _currentUser = null;
      if (!keepRememberMe) {
        _rememberMe = false;
      }
      notifyListeners();
      print('✅ Logged out (business data preserved)');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  // Check if user exists
  Future<bool> hasUser() async {
    final users = await _sessionManager.getAllUsers();
    return users.isNotEmpty;
  }

  // Get all users (for multi-user support)
  Future<List<UserModel>> getAllUsers() async {
    return await _sessionManager.getAllUsers();
  }

  // Switch to different user
  Future<bool> switchUser(String userId, String pin) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate PIN
      final isValid = await _sessionManager.validatePin(userId, pin);
      if (!isValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Switch user
      final user = await _sessionManager.switchUser(userId);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      print('✅ Switched to user: ${user.name}');
      return true;
    } catch (e) {
      print('❌ Error switching user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user PIN
  Future<bool> updatePin(String oldPin, String newPin) async {
    try {
      if (_currentUser == null) return false;

      // Validate old PIN
      final isValid = await _sessionManager.validatePin(_currentUser!.id, oldPin);
      if (!isValid) return false;

      // Update PIN
      await _sessionManager.updateUserPin(_currentUser!.id, newPin);
      print('✅ PIN updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating PIN: $e');
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount(String userId) async {
    try {
      await _sessionManager.deleteUserAccount(userId);
      
      // If deleted current user, logout
      if (_currentUser?.id == userId) {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('❌ Error deleting account: $e');
      return false;
    }
  }

  // Get session info (for debugging)
  Future<Map<String, dynamic>> getSessionInfo() async {
    return await _sessionManager.getSessionInfo();
  }

  // Set security answer for PIN recovery
  Future<void> setSecurityAnswer(String answer) async {
    if (_currentUser == null) return;
    await _sessionManager.setSecurityAnswer(_currentUser!.id, answer);
  }

  // Check if security answer is set
  Future<bool> hasSecurityAnswer() async {
    if (_currentUser == null) return false;
    return await _sessionManager.hasSecurityAnswer(_currentUser!.id);
  }

  // Check if security answer is set for specific user
  Future<bool> hasSecurityAnswerForUser(String userId) async {
    return await _sessionManager.hasSecurityAnswer(userId);
  }

  // Reset PIN using security answer
  Future<bool> resetPinWithSecurityAnswer({
    required String userId,
    required String securityAnswer,
    required String newPin,
  }) async {
    try {
      final success = await _sessionManager.resetPinWithSecurityAnswer(
        userId: userId,
        securityAnswer: securityAnswer,
        newPin: newPin,
      );

      if (success) {
        print('✅ PIN reset successful');
      }
      return success;
    } catch (e) {
      print('❌ Error resetting PIN: $e');
      return false;
    }
  }

  // Emergency PIN reset (last resort)
  Future<bool> emergencyResetPin({
    required String userId,
    required String newPin,
  }) async {
    try {
      return await _sessionManager.emergencyResetPin(userId, newPin);
    } catch (e) {
      print('❌ Error in emergency reset: $e');
      return false;
    }
  }

  // Get last user ID
  Future<String?> get lastUserId async {
    return await _sessionManager.getLastUserId();
  }
}
