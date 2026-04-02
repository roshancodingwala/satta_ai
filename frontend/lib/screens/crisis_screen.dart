import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  static const List<Map<String, String>> _helplines = [
    {
      'name': 'iCall — TISS',
      'number': '9152987821',
      'hours': 'Mon–Sat, 8am–10pm',
      'icon': '📞',
    },
    {
      'name': 'Vandrevala Foundation',
      'number': '1860-2662-345',
      'hours': '24/7',
      'icon': '💚',
    },
    {
      'name': 'NIMHANS Bengaluru',
      'number': '080-46110007',
      'hours': '24/7',
      'icon': '🏥',
    },
    {
      'name': 'iMind Helpline',
      'number': '4422',
      'hours': '24/7',
      'icon': '🤝',
    },
  ];

  Future<void> _callNumber(String number) async {
    final clean = number.replaceAll('-', '').replaceAll(' ', '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A0A), Color(0xFF0D0B1E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                _buildHeartIcon(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildMessage(),
                const SizedBox(height: 32),
                _buildHelplinesSection(),
                const SizedBox(height: 32),
                _buildAffirmation(),
                const SizedBox(height: 32),
                _buildBackButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.danger.withOpacity(0.15),
        border: Border.all(color: AppTheme.danger.withOpacity(0.4), width: 2),
      ),
      child: const Center(
        child: Text('💙', style: TextStyle(fontSize: 42)),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Help is Available',
          style: AppTheme.displayLarge.copyWith(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'आप अकेले नहीं हैं · You Are Not Alone',
          style: AppTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
      ),
      child: Text(
        'It seems you may be going through an extremely difficult moment. '
        'Your feelings are valid and you deserve support. '
        'Please reach out to a trained counsellor right now — '
        'they are ready to listen, without judgment.',
        style: AppTheme.bodyLarge.copyWith(height: 1.7),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHelplinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Indian Mental Health Helplines', style: AppTheme.titleLarge),
        const SizedBox(height: 14),
        ..._helplines.map((h) => _buildHelplineCard(h)),
      ],
    );
  }

  Widget _buildHelplineCard(Map<String, String> helpline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Text(helpline['icon']!, style: const TextStyle(fontSize: 28)),
        title: Text(helpline['name']!, style: AppTheme.titleLarge.copyWith(fontSize: 15)),
        subtitle: Text('⏰ ${helpline['hours']}',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.accent)),
        trailing: GestureDetector(
          onTap: () => _callNumber(helpline['number']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.danger.withOpacity(0.5)),
            ),
            child: Text(
              helpline['number']!,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.danger,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.12),
            AppTheme.secondary.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🪷', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            '"यह भी बीत जाएगा"\n"This too shall pass."',
            style: AppTheme.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.accent,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '— Ancient Sanskrit wisdom',
            style: AppTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
        context, '/', (r) => false,
      ),
      icon: const Icon(Icons.home_rounded, color: AppTheme.textSecondary),
      label: Text('Return to Safety', style: AppTheme.bodyMedium),
    );
  }
}
