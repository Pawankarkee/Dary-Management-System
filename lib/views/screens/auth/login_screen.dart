import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../layouts/main_layout.dart';
import 'register_screen.dart';
import 'forgot_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _rememberMe = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadRememberMePreference();
  }

  Future<void> _checkBiometric() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final isAvailable = await authController.checkBiometricAvailability();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _loadRememberMePreference() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    setState(() {
      _rememberMe = authController.rememberMe;
    });
  }

  Future<void> _loginWithPin() async {
    if (_pinController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter PIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.loginWithPin(
      _pinController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid PIN';
        _isLoading = false;
      });
      _pinController.clear();
    }
  }

  Future<void> _loginWithBiometric() async {
    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.loginWithBiometric(
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndNavigate() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final hasUser = await authController.hasUser();

    if (!mounted) return;

    if (!hasUser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = Provider.of<ThemeController>(context);
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsiveValue(
                context,
                mobile: 24,
                tablet: 48,
                desktop: 64,
              ),
              vertical: isMobile ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : (isMobile ? double.infinity : 500),
                minHeight: size.height - MediaQuery.of(context).padding.top - (isMobile ? 32 : 48),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Theme Toggle - Responsive position
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => themeController.toggleTheme(),
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: AppTheme.primaryColor,
                        size: isMobile ? 24 : 28,
                      ),
                      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : 32),

                  // Logo - Responsive size
                  Container(
                    width: isMobile ? size.width * 0.35 : 150,
                    height: isMobile ? size.width * 0.35 : 150,
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 140 : 180,
                      maxHeight: isMobile ? 140 : 180,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

                  // Title - Responsive font size
                  Text(
                    'Welcome to Dairify',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 28 : 36,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Login to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: isMobile ? 14 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isMobile ? 40 : 48),

                  // PIN Input - Responsive
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isMobile ? 6 : 8,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter PIN',
                      labelStyle: TextStyle(fontSize: isMobile ? 14 : 16),
                      counterText: '',
                      hintText: '••••••',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: isMobile ? 16 : 18,
                      ),
                    ),
                    onSubmitted: (_) => _loginWithPin(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  if (_errorMessage.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 12 : 16),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: AppTheme.errorColor, size: isMobile ? 18 : 20),
                          SizedBox(width: isMobile ? 8 : 10),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: isMobile ? 12 : 16),

                  // Remember Me Checkbox - Responsive
                  CheckboxListTile(
                    title: Text(
                      'Remember Me',
                      style: TextStyle(fontSize: isMobile ? 13 : 14),
                    ),
                    subtitle: Text(
                      'Auto-login on next app start',
                      style: TextStyle(fontSize: isMobile ? 11 : 12),
                    ),
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: isMobile,
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Login Button - Responsive
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 50 : 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithPin,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: isMobile ? 20 : 24,
                              height: isMobile ? 20 : 24,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Login',
                              style: TextStyle(fontSize: isMobile ? 15 : 16),
                            ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 20 : 24),

                SizedBox(height: isMobile ? 20 : 24),

                  // Biometric Login - Responsive
                  if (_isBiometricAvailable) ...[
                    Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loginWithBiometric,
                      icon: Icon(Icons.fingerprint, size: isMobile ? 24 : 28),
                      label: Text(
                        'Login with Biometric',
                        style: TextStyle(fontSize: isMobile ? 13 : 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                          vertical: isMobile ? 12 : 16,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: isMobile ? 20 : 24),

                  // Register Link - Responsive
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(fontSize: isMobile ? 13 : 14),
                    ),
                  ),

                  SizedBox(height: isMobile ? 4 : 8),

                  // Forgot PIN Link - Responsive
                  TextButton(
                    onPressed: () async {
                      // Get current user ID from AuthController
                      final authController = Provider.of<AuthController>(context, listen: false);
                      final userId = await authController.lastUserId;
                      
                      if (userId != null) {
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ForgotPinScreen(userId: userId),
                          ),
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No user found. Please register first.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
