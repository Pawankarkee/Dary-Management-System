import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'intro_screen.dart';
import 'auth/login_screen.dart';
import '../layouts/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _loadingMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate after splash
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Initial delay for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // Update loading message
    setState(() {
      _loadingMessage = 'Loading local data...';
    });

    final authController = Provider.of<AuthController>(context, listen: false);

    // Check authentication with loading indicator
    await authController.checkAuthentication();

    // If biometric is enabled but not authenticated, try biometric login
    if (!authController.isAuthenticated && authController.isBiometricEnabled) {
      setState(() {
        _loadingMessage = 'Authenticating with biometrics...';
      });
      final ok = await authController.loginWithBiometric(rememberMe: authController.rememberMe);
      if (ok) {
        // small delay to show welcome
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Brief delay to show completion
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Widget nextScreen;
    if (authController.isFirstTime) {
      nextScreen = const IntroScreen();
    } else if (authController.isAuthenticated) {
      setState(() {
        _loadingMessage = 'Welcome back!';
      });
      await Future.delayed(const Duration(milliseconds: 300));
      nextScreen = const MainLayout();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF121212),
                    const Color(0xFF0D47A1),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF2196F3).withOpacity(0.3),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // Logo Container with Shadow
                        Container(
                          width: size.width * 0.45,
                          height: size.width * 0.45,
                          constraints: const BoxConstraints(
                            maxWidth: 250,
                            maxHeight: 250,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // App Name
                        Text(
                          'Dairify',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: const Color(0xFF2196F3),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Tagline
                        Text(
                          'Complete Dairy Management',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? Colors.white70
                                : Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator with Message
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? Colors.white60
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
