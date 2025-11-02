import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../config/theme/app_theme.dart';
import 'login_screen.dart';

class ForgotPinScreen extends StatefulWidget {
  final String userId;

  const ForgotPinScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _securityAnswerController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  // Focus nodes for Enter key navigation
  final _securityAnswerFocusNode = FocusNode();
  final _newPinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  bool _hasSecurityAnswer = false;
  int _currentStep = 0; // 0: Check recovery, 1: Verify answer, 2: Set new PIN

  @override
  void initState() {
    super.initState();
    _checkRecoveryOptions();
  }

  Future<void> _checkRecoveryOptions() async {
    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final hasAnswer = await authController.hasSecurityAnswerForUser(widget.userId);

    setState(() {
      _hasSecurityAnswer = hasAnswer;
      _isLoading = false;
      _currentStep = hasAnswer ? 1 : 0;
    });
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPinController.text != _confirmPinController.text) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.resetPinWithSecurityAnswer(
      userId: widget.userId,
      securityAnswer: _securityAnswerController.text,
      newPin: _newPinController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _successMessage = 'PIN reset successfully!';
        _isLoading = false;
      });

      // Navigate to login after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect security answer. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _emergencyReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Reset'),
        content: const Text(
          'This will reset your PIN without verification. '
          'All your data will remain intact. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (_newPinController.text != _confirmPinController.text) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    if (_newPinController.text.length < 4) {
      setState(() => _errorMessage = 'PIN must be at least 4 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.emergencyResetPin(
      userId: widget.userId,
      newPin: _newPinController.text,
    );

    if (!mounted) return;

    setState(() {
      _successMessage = 'PIN reset successfully!';
      _isLoading = false;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _securityAnswerController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _securityAnswerFocusNode.dispose();
    _newPinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot PIN'),
        centerTitle: true,
      ),
      body: _isLoading && _currentStep == 0
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getResponsiveValue(
                    context,
                    mobile: 24,
                    tablet: 48,
                    desktop: 64,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Reset Your PIN',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _hasSecurityAnswer
                          ? 'Answer your security question to reset your PIN'
                          : 'No security answer found. Use emergency reset.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Form
                    if (_hasSecurityAnswer)
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Security Question
                            Container(
                              padding: const EdgeInsets.all(16),
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
                                        size: 20,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Security Question',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'What is your favorite dairy product?',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Answer Field
                            TextFormField(
                              controller: _securityAnswerController,
                              focusNode: _securityAnswerFocusNode,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Your Answer',
                                hintText: 'Enter your answer',
                                prefixIcon: Icon(Icons.question_answer),
                              ),
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_newPinFocusNode);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your answer';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // New PIN
                            TextFormField(
                              controller: _newPinController,
                              focusNode: _newPinFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'New PIN (4-6 digits)',
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
                                  return 'Please enter a new PIN';
                                }
                                if (value.length < 4) {
                                  return 'PIN must be at least 4 digits';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Confirm PIN
                            TextFormField(
                              controller: _confirmPinController,
                              focusNode: _confirmPinFocusNode,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirm New PIN',
                                prefixIcon: Icon(Icons.lock_outline),
                                counterText: '',
                              ),
                              onFieldSubmitted: (_) => _resetPin(),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your PIN';
                                }
                                if (value != _newPinController.text) {
                                  return 'PINs do not match';
                                }
                                return null;
                              },
                            ),

                            if (_errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.errorColor),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(
                                          color: AppTheme.errorColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (_successMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.successColor),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successMessage,
                                        style: TextStyle(
                                          color: AppTheme.successColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Reset Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _resetPin,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Reset PIN'),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Emergency Reset (No Security Answer)
                    if (!_hasSecurityAnswer) ...[
                      // New PIN
                      TextFormField(
                        controller: _newPinController,
                        focusNode: _newPinFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New PIN (4-6 digits)',
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
                      ),

                      const SizedBox(height: 20),

                      // Confirm PIN
                      TextFormField(
                        controller: _confirmPinController,
                        focusNode: _confirmPinFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New PIN',
                          prefixIcon: Icon(Icons.lock_outline),
                          counterText: '',
                        ),
                        onFieldSubmitted: (_) => _emergencyReset(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),

                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.errorColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_successMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.successColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage,
                                  style: TextStyle(
                                    color: AppTheme.successColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Emergency Reset Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _emergencyReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Emergency Reset PIN'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Warning
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Emergency reset is available because you did not set up a security answer during registration.',
                                style: TextStyle(
                                  color: isDark ? Colors.orange[300] : Colors.orange[900],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Back to Login
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
