import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _characterController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to CyberRent',
      subtitle: 'Experience the future of car rentals',
      description:
          'Discover premium vehicles with cutting-edge technology and unmatched luxury.',
      icon: Icons.electric_car,
      gradient: CyberpunkTheme.primaryGradient,
    ),
    OnboardingPage(
      title: 'Seamless Booking',
      subtitle: 'Book your dream car in seconds',
      description:
          'Our intelligent system finds the perfect vehicle for your needs and budget.',
      icon: Icons.speed,
      gradient: const LinearGradient(
        colors: [CyberpunkTheme.secondaryNeon, CyberpunkTheme.accentNeon],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      title: 'Premium Experience',
      subtitle: 'Luxury meets technology',
      description:
          'Enjoy world-class service with our premium fleet and concierge support.',
      icon: Icons.star,
      gradient: const LinearGradient(
        colors: [CyberpunkTheme.accentNeon, CyberpunkTheme.warningNeon],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _characterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header with character
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeInLeft(
                      child: CyberpunkTheme.neonText(
                        'CYBER RENT',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FadeInRight(
                      child: CyberpunkCharacter(size: 60, isAnimated: true),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page indicators
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),

              // Bottom actions
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              // Navigate to home screen
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberpunkTheme.primaryNeon,
                            foregroundColor: CyberpunkTheme.darkBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Rajdhani',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: CyberpunkTheme.textSecondary,
                            fontSize: 16,
                            fontFamily: 'Rajdhani',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          FadeInDown(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: page.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: page.gradient.colors.first.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 60,
                color: CyberpunkTheme.darkBackground,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              page.title,
              style: TextStyle(
                color: CyberpunkTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              page.subtitle,
              style: TextStyle(
                color: CyberpunkTheme.primaryNeon,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Rajdhani',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              page.description,
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Rajdhani',
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 30 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? CyberpunkTheme.primaryNeon
            : CyberpunkTheme.textMuted,
        borderRadius: BorderRadius.circular(5),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: CyberpunkTheme.primaryNeon.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
