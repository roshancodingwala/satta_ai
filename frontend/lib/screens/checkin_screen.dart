import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:record/record.dart';
import '../theme/app_theme.dart';
import '../providers/emotion_provider.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Voice recording
  final AudioRecorder _recorder = AudioRecorder();
  bool _isVoiceMode = false;
  bool _isRecording = false;
  String? _recordedPath;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _recorder.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop
      final path = await _recorder.stop();
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } else {
      // Start
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;
      final path =
          '${DateTime.now().millisecondsSinceEpoch}_voice.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _recordedPath = null;
        _recordSeconds = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordSeconds++);
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<EmotionProvider>();

    if (_isVoiceMode) {
      if (_recordedPath == null) return;
      await provider.performCheckInVoice(_recordedPath!);
    } else {
      final text = _textCtrl.text.trim();
      if (text.isEmpty) return;
      await provider.performCheckIn(text);
    }

    if (!mounted) return;

    if (provider.emotionData?.isCrisis == true) {
      Navigator.pushReplacementNamed(context, '/crisis',
          arguments: provider.emotionData?.helplines);
    } else if (provider.state == EmotionState.success) {
      Navigator.pushReplacementNamed(context, '/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModeToggle(),
                      const SizedBox(height: 20),
                      _buildPromptCard(),
                      const SizedBox(height: 24),
                      _isVoiceMode
                          ? _buildVoicePanel()
                          : _buildTextInput(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(context),
                      const SizedBox(height: 20),
                      _buildErrorWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _modeTab('🖊️  Text', !_isVoiceMode, () {
            setState(() => _isVoiceMode = false);
          }),
          _modeTab('🎙️  Voice', _isVoiceMode, () {
            setState(() => _isVoiceMode = true);
          }),
        ],
      ),
    );
  }

  Widget _modeTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.saffronGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: active ? Colors.white : AppTheme.textSecondary,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoicePanel() {
    final hasRecording = _recordedPath != null;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isRecording
                  ? AppTheme.danger.withOpacity(0.5)
                  : AppTheme.secondary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Mic button
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isRecording
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFCC3333)])
                        : AppTheme.saffronGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? AppTheme.danger
                                : AppTheme.primary)
                            .withOpacity(0.45),
                        blurRadius: _isRecording ? 32 : 16,
                        spreadRadius: _isRecording ? 6 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isRecording
                    ? Column(
                        key: const ValueKey('recording'),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.danger,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recording… ${_recordSeconds}s',
                                style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.danger),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the button to stop',
                            style: AppTheme.labelSmall,
                          ),
                        ],
                      )
                    : hasRecording
                        ? Column(
                            key: const ValueKey('done'),
                            children: [
                              const Text('✅',
                                  style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text('Recording ready! (${_recordSeconds}s)',
                                  style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.success)),
                              Text('Tap below to seek wisdom',
                                  style: AppTheme.labelSmall),
                            ],
                          )
                        : Column(
                            key: const ValueKey('idle'),
                            children: [
                              Text('Tap the mic to record', style: AppTheme.bodyMedium),
                              const SizedBox(height: 4),
                              Text('Speak freely about how you feel',
                                  style: AppTheme.labelSmall),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text('How are you feeling?', style: AppTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.2), width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text('Check-in Guidance', style: AppTheme.titleLarge.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Describe your current emotional state freely. '
            'Share what is troubling your mind or weighing on your heart. '
            'SattvaAI will offer ancient wisdom to reframe your challenge.',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppTheme.surfaceLight, height: 1),
          const SizedBox(height: 10),
          Text(
            "Example: \"I keep failing at work and feel like I'm not good enough...\"",
            style: AppTheme.labelSmall.copyWith(
              fontStyle: FontStyle.italic, color: AppTheme.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your words  🖊️', style: AppTheme.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _textCtrl,
          maxLines: 6,
          minLines: 4,
          style: AppTheme.bodyLarge,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Type freely — this is a safe space…',
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
          onChanged: (val) => context.read<EmotionProvider>().setInputText(val),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<EmotionProvider>(
      builder: (_, provider, __) {
        final isLoading = provider.state == EmotionState.loading;
        return GestureDetector(
          onTap: isLoading ? null : () => _submit(context),
          child: AnimatedScale(
            scale: isLoading ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: isLoading
                    ? LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.5),
                          AppTheme.primaryDark.withOpacity(0.5),
                        ],
                      )
                    : AppTheme.saffronGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (!isLoading)
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SpinKitThreeBounce(
                        color: Colors.white, size: 28)
                    : Text(
                        '🙏  Seek Wisdom',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Consumer<EmotionProvider>(
      builder: (_, provider, __) {
        if (provider.state != EmotionState.error) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.errorMessage ?? 'Something went wrong. Please try again.',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
