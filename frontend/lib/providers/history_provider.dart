/// history_provider.dart
/// Stores mood check-in history locally using SharedPreferences.
/// Each entry captures: date, emotion, stressLevel, energyFrequency, fable, niti.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final DateTime date;
  final String primaryEmotion;
  final int stressLevel;
  final String energyFrequency;
  final String? fable;
  final String? niti;
  final String? raagaName;

  const HistoryEntry({
    required this.date,
    required this.primaryEmotion,
    required this.stressLevel,
    required this.energyFrequency,
    this.fable,
    this.niti,
    this.raagaName,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'primaryEmotion': primaryEmotion,
        'stressLevel': stressLevel,
        'energyFrequency': energyFrequency,
        'fable': fable,
        'niti': niti,
        'raagaName': raagaName,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        date: DateTime.parse(json['date'] as String),
        primaryEmotion: json['primaryEmotion'] as String? ?? 'unknown',
        stressLevel: (json['stressLevel'] as num?)?.toInt() ?? 5,
        energyFrequency: json['energyFrequency'] as String? ?? 'medium',
        fable: json['fable'] as String?,
        niti: json['niti'] as String?,
        raagaName: json['raagaName'] as String?,
      );
}

class HistoryProvider extends ChangeNotifier {
  static const _key = 'sattva_history';
  List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  List<HistoryEntry> get recentEntries =>
      _entries.take(30).toList(); // last 30

  double get averageStress {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.stressLevel).reduce((a, b) => a + b) /
        _entries.length;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = json.decode(raw) as List<dynamic>;
      _entries = list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // newest first
    } catch (_) {
      _entries = [];
    }
    notifyListeners();
  }

  Future<void> addEntry(HistoryEntry entry) async {
    _entries.insert(0, entry);
    if (_entries.length > 100) _entries = _entries.take(100).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _entries = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_entries.map((e) => e.toJson()).toList()),
    );
  }
}
