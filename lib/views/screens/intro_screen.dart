import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: 'Welcome to Dairify',
      description: 'Complete dairy management system designed for dairy shop owners. Manage milk collection, farmers, payments, and inventory all in one place.',
      icon: Icons.water_drop,
      color: const Color(0xFF2196F3),
    ),
    IntroPage(
      title: 'Works Offline',
      description: 'No internet? No problem! Dairify works seamlessly offline and automatically syncs your data when you\'re back online.',
      icon: Icons.cloud_off,
      color: const Color(0xFF4CAF50),
    ),
    IntroPage(
      title: 'Easy & Powerful',
      description: 'Track milk collection, manage farmer accounts, handle payments, maintain stock, and generate detailed reports with just a few taps.',
      icon: Icons.insights,
      color: const Color(0xFFFF9800),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipIntro() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.completeIntro();
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skipIntro();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo at Top
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dairify',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipIntro,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], size, isDark);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPage page, Size size, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon with Logo Background
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular background with gradient
              Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                constraints: const BoxConstraints(
                  maxWidth: 280,
                  maxHeight: 280,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      page.color.withOpacity(0.2),
                      page.color.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Icon
              Container(
                width: size.width * 0.35,
                height: size.width * 0.35,
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: size.width * 0.2,
                  color: page.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : _pages[_currentPage].color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
