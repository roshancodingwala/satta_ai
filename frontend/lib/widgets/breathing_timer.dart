/// Standalone BreathingTimer widget and controller.
/// The BreathingController is fully implemented inside mandala_painter.dart.
/// This file re-exports it as a convenience import and adds a standalone
/// BreathingTimerWidget that can be used independently of the Mandala.
library breathing_timer;

export 'mandala_painter.dart' show BreathingController, BreathCycle, BreathPhase;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'mandala_painter.dart';

/// A standalone circular breathing timer widget.
/// Shows the phase label, countdown progress ring, and phase name.
class BreathingTimerWidget extends StatefulWidget {
  final BreathingController controller;
  final double size;

  const BreathingTimerWidget({
    super.key,
    required this.controller,
    this.size = 160,
  });

  @override
  State<BreathingTimerWidget> createState() => _BreathingTimerWidgetState();
}

class _BreathingTimerWidgetState extends State<BreathingTimerWidget> {
  BreathCycle? _current;

  @override
  void initState() {
    super.initState();
    widget.controller.stream.listen((cycle) {
      if (mounted) setState(() => _current = cycle);
    });
    widget.controller.start();
  }

  Color _phaseColor(BreathPhase? phase) {
    switch (phase) {
      case BreathPhase.inhale:   return AppTheme.accent;
      case BreathPhase.hold:     return AppTheme.primary;
      case BreathPhase.exhale:   return AppTheme.secondary;
      case BreathPhase.holdOut:  return AppTheme.textSecondary;
      case null:                 return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _current?.phase;
    final progress = _current?.progress ?? 0.0;
    final label = _current?.label ?? 'Starting…';
    final color = _phaseColor(phase);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.split('·').first.trim(),
                style: AppTheme.labelSmall.copyWith(color: color, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                label.contains('·') ? label.split('·').last.trim() : '',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
