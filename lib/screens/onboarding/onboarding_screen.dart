import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: Icons.security_rounded,
      color1: Color(0xFF6C63FF),
      color2: Color(0xFF9C97FF),
      title: 'Secure Voting',
      description:
          'Cast your vote securely with end-to-end encryption and multi-step identity verification. Your vote is private and protected.',
    ),
    const _OnboardingPage(
      icon: Icons.bar_chart_rounded,
      color1: Color(0xFF00D2B4),
      color2: Color(0xFF00A896),
      title: 'Real-time Results',
      description:
          'Watch live vote counts update instantly with beautiful charts and analytics. Track every vote as it happens.',
    ),
    const _OnboardingPage(
      icon: Icons.admin_panel_settings_rounded,
      color1: Color(0xFF667EEA),
      color2: Color(0xFF764BA2),
      title: 'Admin Control',
      description:
          'Administrators have full control to manage candidates, elections, and results with a powerful dashboard.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _pages[i],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: const Text(
                          AppStrings.skip,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color color1;
  final Color color2;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.color1,
    required this.color2,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color1.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
