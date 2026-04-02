/// splash_screen.dart — Animated splash / onboarding for SattvaAI
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/mandala_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _rotCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  int _pageIndex = 0;
  final BreathingController _breathCtrl = BreathingController();

  static const _onboardPages = [
    _OnboardPage(
      emoji: '🧠',
      title: 'Feel Understood',
      subtitle: 'Share how you feel in words or voice.\nour AI listens with empathy.',
      color: AppTheme.primary,
    ),
    _OnboardPage(
      emoji: '🎵',
      title: 'Heal with Raagas',
      subtitle: 'Ancient Indian Classical Raagas\nselected for your stress level.',
      color: AppTheme.secondary,
    ),
    _OnboardPage(
      emoji: '📖',
      title: 'Wisdom Through Stories',
      subtitle: 'Panchatantra fables reframe\nyour challenges into courage.',
      color: AppTheme.accent,
    ),
    _OnboardPage(
      emoji: '🌸',
      title: 'Breathe & Be Still',
      subtitle: 'Mandala-guided 4-7-8 breathing\nbrings you back to yourself.',
      color: AppTheme.success,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    _breathCtrl.start();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _rotCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  void _next(BuildContext context) {
    if (_pageIndex < _onboardPages.length - 1) {
      setState(() => _pageIndex++);
      _fadeCtrl
        ..reset()
        ..forward();
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _skip(BuildContext context) =>
      Navigator.pushReplacementNamed(context, '/');

  @override
  Widget build(BuildContext context) {
    final page = _onboardPages[_pageIndex];
    final isLast = _pageIndex == _onboardPages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextButton(
                    onPressed: () => _skip(context),
                    child: Text(
                      'Skip',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),

              // Mandala
              Expanded(
                flex: 4,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _rotCtrl,
                    builder: (_, __) => ScaleTransition(
                      scale: _scaleAnim,
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: MandalaPainter(
                          scale: 1.0,
                          rotationAngle: _rotCtrl.value * 2 * math.pi,
                          primaryColor: page.color,
                          secondaryColor:
                              page.color.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page.emoji,
                            style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 20),
                        Text(
                          page.title,
                          style: AppTheme.displayLarge
                              .copyWith(fontSize: 28, color: page.color),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.subtitle,
                          style: AppTheme.bodyLarge.copyWith(height: 1.7),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Dots + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardPages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _pageIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _pageIndex
                                ? AppTheme.primary
                                : AppTheme.surfaceLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // CTA button
                    GestureDetector(
                      onTap: () => _next(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.saffronGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isLast ? '🙏  Begin Your Journey' : 'Next  →',
                            style: AppTheme.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
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
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
