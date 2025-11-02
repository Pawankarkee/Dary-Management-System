import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../layouts/main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  
  // Focus nodes for Enter key navigation
  final _nameFocusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();
  final _securityAnswerFocusNode = FocusNode();
  
  UserRole _selectedRole = UserRole.admin;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showSecurityQuestion = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text != _confirmPinController.text) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.register(
      name: _nameController.text,
      pin: _pinController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      // Save security answer if provided
      if (_showSecurityQuestion && _securityAnswerController.text.isNotEmpty) {
        await authController.setSecurityAnswer(_securityAnswerController.text);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _securityAnswerController.dispose();
    _nameFocusNode.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    _securityAnswerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              vertical: isMobile ? 24 : 32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : (isMobile ? double.infinity : 500),
                minHeight: size.height - MediaQuery.of(context).padding.top - (isMobile ? 48 : 64),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: isMobile ? size.width * 0.3 : 120,
                    height: isMobile ? size.width * 0.3 : 120,
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 120 : 150,
                      maxHeight: isMobile ? 120 : 150,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

                  // Title
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 28 : 36,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Register to start using Dairify',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: isMobile ? 14 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isMobile ? 32 : 48),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          onFieldSubmitted: (_) {
                            // Skip to PIN field (role dropdown is not a text field)
                            FocusScope.of(context).requestFocus(_pinFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Role Selection
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.admin,
                            child: Text('Admin (Full Access)'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.collector,
                            child: Text('Collector (Limited Access)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedRole = value);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // PIN Field
                      TextFormField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Create PIN (4-6 digits)',
                          prefixIcon: Icon(Icons.lock),
                          counterText: '',
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmPinFocusNode);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a PIN';
                          }
                          if (value.length < 4) {
                            return 'PIN must be at least 4 digits';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm PIN Field
                      TextFormField(
                        controller: _confirmPinController,
                        focusNode: _confirmPinFocusNode,
                        textInputAction: _showSecurityQuestion 
                            ? TextInputAction.next 
                            : TextInputAction.done,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm PIN',
                          prefixIcon: Icon(Icons.lock_outline),
                          counterText: '',
                        ),
                        onFieldSubmitted: (_) {
                          if (_showSecurityQuestion) {
                            FocusScope.of(context).requestFocus(_securityAnswerFocusNode);
                          } else {
                            _register();
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your PIN';
                          }
                          if (value != _pinController.text) {
                            return 'PINs do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Security Question Toggle - Responsive
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showSecurityQuestion = !_showSecurityQuestion;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: _showSecurityQuestion
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _showSecurityQuestion
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: _showSecurityQuestion
                                    ? AppTheme.primaryColor
                                    : (isDark ? Colors.white60 : Colors.black45),
                                size: isMobile ? 20 : 24,
                              ),
                              SizedBox(width: isMobile ? 10 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Setup PIN Recovery (Recommended)',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: isMobile ? 13 : 14,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 2 : 4),
                                    Text(
                                      'Add a security answer to recover your PIN if forgotten',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: isMobile ? 11 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Security Answer Field (Conditional) - Animated
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showSecurityQuestion
                            ? Column(
                                children: [
                                  SizedBox(height: isMobile ? 16 : 20),
                                  Container(
                                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.help_outline,
                                              size: isMobile ? 18 : 20,
                                              color: AppTheme.primaryColor,
                                            ),
                                            SizedBox(width: isMobile ? 6 : 8),
                                            Expanded(
                                              child: Text(
                                                'Security Question',
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isMobile ? 13 : 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isMobile ? 10 : 12),
                                        Text(
                                          'What is your favorite dairy product?',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                        ),
                                        SizedBox(height: isMobile ? 12 : 16),
                                        TextFormField(
                                          controller: _securityAnswerController,
                                          focusNode: _securityAnswerFocusNode,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            labelText: 'Your Answer',
                                            labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                                            hintText: 'e.g., Milk, Cheese, Yogurt',
                                            hintStyle: TextStyle(fontSize: isMobile ? 11 : 12),
                                            prefixIcon: Icon(Icons.question_answer, size: isMobile ? 20 : 24),
                                            filled: true,
                                            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: isMobile ? 12 : 16,
                                              vertical: isMobile ? 12 : 16,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                                          onFieldSubmitted: (_) => _register(),
                                          validator: (value) {
                                            if (_showSecurityQuestion && (value == null || value.isEmpty)) {
                                              return 'Please provide an answer';
                                            }
                                            if (_showSecurityQuestion && value!.length < 3) {
                                              return 'Answer must be at least 3 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
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
                            children: [
                              Icon(Icons.error_outline, color: AppTheme.errorColor, size: isMobile ? 18 : 20),
                              SizedBox(width: isMobile ? 8 : 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: isMobile ? 24 : 32),

                      // Register Button - Responsive
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 50 : 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                                  'Register',
                                  style: TextStyle(fontSize: isMobile ? 15 : 16),
                                ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),

                      // Back to Login - Responsive
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
