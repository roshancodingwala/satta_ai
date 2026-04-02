import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Breathing Phase ──────────────────────────────────────────────────────
enum BreathPhase { inhale, hold, exhale, holdOut }

class BreathCycle {
  final BreathPhase phase;
  final String label;
  final double progress; // 0.0–1.0 within this phase
  final double globalScale; // mandala scale value 0.7–1.3

  const BreathCycle({
    required this.phase,
    required this.label,
    required this.progress,
    required this.globalScale,
  });
}

/// 4-7-8 breathing controller exposing a Stream<BreathCycle>
class BreathingController {
  // Durations in seconds: Inhale=4, Hold=7, Exhale=8, HoldOut=1
  static const _phases = [
    (BreathPhase.inhale,  'इनहेल  · Breathe In',  4),
    (BreathPhase.hold,    'होल्ड  · Hold',         7),
    (BreathPhase.exhale,  'एग्जेल · Breathe Out',  8),
    (BreathPhase.holdOut, 'रुकें  · Rest',          1),
  ];

  final _controller = StreamController<BreathCycle>.broadcast();
  Timer? _timer;
  bool _running = false;

  Stream<BreathCycle> get stream => _controller.stream;

  void start() {
    if (_running) return;
    _running = true;
    _runCycle();
  }

  void _runCycle() async {
    if (!_running) return;
    for (final phaseData in _phases) {
      if (!_running) break;
      final (phase, label, durationSecs) = phaseData;
      final totalTicks = durationSecs * 20; // 50ms ticks → 20 per second
      for (int tick = 0; tick <= totalTicks && _running; tick++) {
        final progress = tick / totalTicks;
        final scale = _computeScale(phase, progress);
        _controller.add(BreathCycle(
          phase: phase,
          label: label,
          progress: progress,
          globalScale: scale,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    _runCycle(); // loop
  }

  double _computeScale(BreathPhase phase, double progress) {
    switch (phase) {
      case BreathPhase.inhale:
        return 0.75 + 0.55 * progress;   // 0.75 → 1.30
      case BreathPhase.hold:
        return 1.30;
      case BreathPhase.exhale:
        return 1.30 - 0.55 * progress;   // 1.30 → 0.75
      case BreathPhase.holdOut:
        return 0.75;
    }
  }

  void stop() {
    _running = false;
    _timer?.cancel();
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

// ── Mandala Painter ────────────────────────────────────────────────────────
class MandalaPainter extends CustomPainter {
  final double scale;         // from BreathingController.globalScale
  final double rotationAngle; // continuous rotation
  final Color primaryColor;
  final Color secondaryColor;

  MandalaPainter({
    this.scale = 1.0,
    this.rotationAngle = 0.0,
    this.primaryColor = AppTheme.primary,
    this.secondaryColor = AppTheme.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.shortestSide / 2) * scale;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    _drawPetalRing(canvas, radius: maxRadius * 0.38, petals: 8,   color: primaryColor.withOpacity(0.25));
    _drawPetalRing(canvas, radius: maxRadius * 0.58, petals: 12,  color: secondaryColor.withOpacity(0.20));
    _drawPetalRing(canvas, radius: maxRadius * 0.75, petals: 16,  color: primaryColor.withOpacity(0.15));
    _drawPetalRing(canvas, radius: maxRadius * 0.90, petals: 24,  color: secondaryColor.withOpacity(0.10));

    // Counter-rotate inner detail
    canvas.rotate(-rotationAngle * 1.5);
    _drawGeometricCore(canvas, maxRadius * 0.28, primaryColor);

    canvas.restore();
  }

  void _drawPetalRing(Canvas canvas, {
    required double radius,
    required int petals,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final angleStep = (2 * math.pi) / petals;
    final petalWidth = radius * 0.30;

    for (int i = 0; i < petals; i++) {
      final angle = i * angleStep;
      canvas.save();
      canvas.rotate(angle);

      final path = Path();
      path.moveTo(0, 0);
      path.cubicTo(
        petalWidth, radius * 0.3,
        petalWidth, radius * 0.7,
        0, radius,
      );
      path.cubicTo(
        -petalWidth, radius * 0.7,
        -petalWidth, radius * 0.3,
        0, 0,
      );

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawGeometricCore(Canvas canvas, double radius, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Star of David layered hexagons
    for (int ring = 1; ring <= 3; ring++) {
      final r = radius * (ring / 3);
      final path = Path();
      for (int i = 0; i <= 6; i++) {
        final a = (i * 60 - 30) * math.pi / 180;
        final x = r * math.cos(a);
        final y = r * math.sin(a);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint..color = color.withOpacity(0.4 + ring * 0.1));
    }

    // Center dot
    canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(MandalaPainter old) =>
      old.scale != scale || old.rotationAngle != rotationAngle;
}

// ── Animated Mandala Widget ───────────────────────────────────────────────
class AnimatedMandala extends StatefulWidget {
  final Stream<BreathCycle>? breathStream;
  final double size;
  final bool animate;

  const AnimatedMandala({
    super.key,
    this.breathStream,
    this.size = 280,
    this.animate = true,
  });

  @override
  State<AnimatedMandala> createState() => _AnimatedMandalaState();
}

class _AnimatedMandalaState extends State<AnimatedMandala>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotController;
  double _scale = 1.0;
  String _breathLabel = '';

  StreamSubscription<BreathCycle>? _sub;

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _sub = widget.breathStream?.listen((cycle) {
      if (mounted) {
        setState(() {
          _scale = cycle.globalScale;
          _breathLabel = cycle.label;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotController,
            builder: (_, __) => AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: MandalaPainter(
                  scale: 1.0,
                  rotationAngle: _rotController.value * 2 * math.pi,
                ),
              ),
            ),
          ),
          if (_breathLabel.isNotEmpty)
            Text(
              _breathLabel,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
