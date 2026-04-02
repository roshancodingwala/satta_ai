import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/emotion_provider.dart';
import '../widgets/mandala_painter.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  final BreathingController _breathCtrl = BreathingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _breathCtrl.start();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Consumer<EmotionProvider>(
            builder: (_, provider, __) {
              final data = provider.emotionData;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }
              return FadeTransition(
                opacity: _fadeAnim,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(context),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildEmotionCard(data),
                          const SizedBox(height: 20),
                          _buildBreathingMandala(),
                          const SizedBox(height: 20),
                          _buildRaagaCard(data),
                          const SizedBox(height: 20),
                          _buildFableCard(data),
                          const SizedBox(height: 20),
                          _buildNitiCard(data),
                          const SizedBox(height: 32),
                          _buildResetButton(context, provider),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 18),
        ),
      ),
      title: Text('Your Wellness Report', style: AppTheme.titleLarge),
      centerTitle: true,
    );
  }

  Widget _buildEmotionCard(EmotionData data) {
    final emotionEmoji = _emotionEmoji(data.primaryEmotion);
    final stressColor = _stressColor(data.stressLevel);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: stressColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emotionEmoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Primary Emotion', style: AppTheme.labelSmall),
                    Text(
                      data.primaryEmotion.capitalize(),
                      style: AppTheme.headlineMedium.copyWith(
                        color: stressColor,
                      ),
                    ),
                  ],
                ),
              ),
              _stressChip(data.stressLevel, stressColor),
            ],
          ),
          if (data.emotionDetail != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppTheme.surfaceLight, height: 1),
            const SizedBox(height: 12),
            Text(data.emotionDetail!, style: AppTheme.bodyMedium.copyWith(height: 1.6)),
          ],
          const SizedBox(height: 14),
          _buildEnergyBar(data.energyFrequency),
        ],
      ),
    );
  }

  Widget _stressChip(int level, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            '$level/10',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text('Stress', style: AppTheme.labelSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEnergyBar(String energy) {
    final fillFraction = energy == 'high' ? 1.0 : energy == 'medium' ? 0.55 : 0.25;
    final energyColor = energy == 'high'
        ? AppTheme.success
        : energy == 'medium'
            ? AppTheme.primary
            : AppTheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Energy Frequency', style: AppTheme.labelSmall),
            Text(energy.toUpperCase(),
                style: AppTheme.labelSmall.copyWith(
                    color: energyColor, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fillFraction,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation(energyColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingMandala() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('4-7-8 Breathing Mandala', style: AppTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Follow the Mandala\'s expansion and contraction',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedMandala(
            breathStream: _breathCtrl.stream,
            size: 220,
          ),
          const SizedBox(height: 12),
          Text(
            'Inhale 4s · Hold 7s · Exhale 8s',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildRaagaCard(EmotionData data) {
    final raaga = data.raaga;
    if (raaga == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1040), Color(0xFF16122E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎵', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raaga Therapy', style: AppTheme.labelSmall),
                    Text(
                      raaga['raaga_name'] ?? '',
                      style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.secondary, fontSize: 17),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  raaga['instrument'] ?? '',
                  style: AppTheme.labelSmall
                      .copyWith(color: AppTheme.secondary, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            raaga['mood_descriptor'] ?? '',
            style: AppTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Text(
            raaga['description'] ?? '',
            style: AppTheme.bodyMedium.copyWith(height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _buildFableCard(EmotionData data) {
    if (data.fable == null || data.fable!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text('Panchatantra Wisdom',
                  style: AppTheme.titleLarge.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.fable!,
            style: AppTheme.bodyLarge.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _buildNitiCard(EmotionData data) {
    if (data.niti == null || data.niti!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.secondary.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        children: [
          const Text('🪷', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text(
            'नीति · Niti (The Moral)',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: 10),
          Text(
            '"${data.niti}"',
            style: AppTheme.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textPrimary,
              height: 1.75,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, EmotionProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.reset();
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('New Check-in', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }

  Color _stressColor(int level) {
    if (level >= 8) return AppTheme.danger;
    if (level >= 5) return AppTheme.primary;
    if (level >= 3) return const Color(0xFFFFD166);
    return AppTheme.success;
  }

  String _emotionEmoji(String emotion) {
    const map = {
      'anxiety': '😰', 'anxious': '😰',
      'sadness': '😔', 'sad': '😔',
      'anger': '😤', 'angry': '😤',
      'fear': '😨',
      'joy': '😊', 'happy': '😊',
      'stress': '😖', 'stressed': '😖',
      'hopeless': '😞', 'hopelessness': '😞',
      'overwhelmed': '🌊',
      'neutral': '😐',
      'calm': '🧘', 'peace': '🧘',
    };
    return map[emotion.toLowerCase()] ?? '🌿';
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
