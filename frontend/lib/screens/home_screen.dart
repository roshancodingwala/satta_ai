import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/mandala_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final BreathingController _breathCtrl = BreathingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    _breathCtrl.start();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const Spacer(),
                  _buildMandala(),
                  const Spacer(),
                  _buildCheckInButton(context),
                  const SizedBox(height: 16),
                  _buildSubtitle(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // History button top right
        Positioned(
          right: 20,
          top: 0,
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondary.withOpacity(0.3), width: 1),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Om symbol / Sanskrit decoration
            const Text('🕉️', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              'SattvaAI',
              style: AppTheme.displayLarge.copyWith(
                fontSize: 42,
                foreground: Paint()
                  ..shader = AppTheme.saffronGradient.createShader(
                    const Rect.fromLTWH(0, 0, 200, 50),
                  ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'तनाव को पहचानें · शांति को पाएं',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
            Text(
              'Recognize Stress · Find Peace',
              style: AppTheme.labelSmall
                  .copyWith(color: AppTheme.textSecondary.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildMandala() {
    return AnimatedMandala(
      breathStream: _breathCtrl.stream,
      size: 260,
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/checkin'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: AppTheme.saffronGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Begin Check-in',
                style: AppTheme.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'Share how you feel — in words or voice',
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pill('🎵 Raaga Therapy'),
            const SizedBox(width: 8),
            _pill('📖 Panchatantra'),
            const SizedBox(width: 8),
            _pill('🌸 Mandala'),
          ],
        ),
      ],
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3), width: 1),
      ),
      child: Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
    );
  }
}
