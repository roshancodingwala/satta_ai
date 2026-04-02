import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

enum EmotionState { idle, loading, success, error }

class EmotionData {
  final String primaryEmotion;
  final int stressLevel;
  final String energyFrequency;
  final String? emotionDetail;
  final bool isCrisis;
  final String? fable;
  final String? niti;
  final Map<String, dynamic>? raaga;
  final List<dynamic> helplines;

  const EmotionData({
    required this.primaryEmotion,
    required this.stressLevel,
    required this.energyFrequency,
    this.emotionDetail,
    this.isCrisis = false,
    this.fable,
    this.niti,
    this.raaga,
    this.helplines = const [],
  });
}

class EmotionProvider extends ChangeNotifier {
  EmotionState _state = EmotionState.idle;
  EmotionData? _emotionData;
  String? _errorMessage;
  String _inputText = '';

  /// Injected by main.dart to save history after each successful check-in.
  Future<void> Function(EmotionData)? onCheckInComplete;

  // ── Getters ────────────────────────────────────────────────────────────
  EmotionState get state => _state;
  EmotionData? get emotionData => _emotionData;
  String? get errorMessage => _errorMessage;
  String get inputText => _inputText;

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  void reset() {
    _state = EmotionState.idle;
    _emotionData = null;
    _errorMessage = null;
    _inputText = '';
    notifyListeners();
  }

  // ── Full Check-in Flow (Text) ──────────────────────────────────────────
  Future<void> performCheckIn(String text) async {
    if (text.trim().isEmpty) return;

    _state = EmotionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final emotionResult = await ApiService.analyzeVibeText(text);
      await _processResults(emotionResult, text);
    } catch (e) {
      _state = EmotionState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // ── Full Check-in Flow (Voice) ─────────────────────────────────────────
  Future<void> performCheckInVoice(String filePath) async {
    _state = EmotionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final file = File(filePath);
      final emotionResult = await ApiService.analyzeVibeAudio(file);
      await _processResults(emotionResult, 'audio input');
    } catch (e) {
      _state = EmotionState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // ── Shared result processing ───────────────────────────────────────────
  Future<void> _processResults(
      Map<String, dynamic> emotionResult, String originalText) async {
    final primaryEmotion =
        emotionResult['primary_emotion'] as String? ?? 'unknown';
    final stressLevel =
        (emotionResult['stress_level'] as num?)?.toInt() ?? 5;
    final energyFreq =
        emotionResult['energy_frequency'] as String? ?? 'medium';
    final emotionDetail = emotionResult['emotion_detail'] as String?;
    final isCrisis = emotionResult['is_crisis'] as bool? ?? false;

    if (isCrisis) {
      _emotionData = EmotionData(
        primaryEmotion: primaryEmotion,
        stressLevel: stressLevel,
        energyFrequency: energyFreq,
        isCrisis: true,
        helplines: const [],
      );
      _state = EmotionState.success;
      return;
    }

    // Parallel calls: wisdom + raaga
    final wisdomFuture = ApiService.wisdomReframe(
      stressor: originalText,
      emotion: primaryEmotion,
      stressLevel: stressLevel,
    );
    final raagaFuture = ApiService.getRaagaForStress(stressLevel);

    final results = await Future.wait([wisdomFuture, raagaFuture]);
    final wisdom = results[0] as Map<String, dynamic>;
    final raaga = results[1] as Map<String, dynamic>;

    if (wisdom['is_crisis'] == true) {
      _emotionData = EmotionData(
        primaryEmotion: primaryEmotion,
        stressLevel: stressLevel,
        energyFrequency: energyFreq,
        isCrisis: true,
        helplines: (wisdom['helplines'] as List?) ?? [],
      );
      _state = EmotionState.success;
      return;
    }

    _emotionData = EmotionData(
      primaryEmotion: primaryEmotion,
      stressLevel: stressLevel,
      energyFrequency: energyFreq,
      emotionDetail: emotionDetail,
      isCrisis: false,
      fable: wisdom['fable'] as String?,
      niti: wisdom['niti'] as String?,
      raaga: raaga,
      helplines: const [],
    );
    _state = EmotionState.success;

    // Save to history
    if (onCheckInComplete != null && _emotionData != null) {
      await onCheckInComplete!(_emotionData!);
    }
  }
}
