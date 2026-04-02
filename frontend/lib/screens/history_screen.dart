/// history_screen.dart — Mood check-in history with stress timeline
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Load history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().load();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
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
            child: Consumer<HistoryProvider>(
              builder: (_, provider, __) {
                final entries = provider.recentEntries;
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(context, provider, entries),
                    if (entries.isEmpty)
                      const SliverFillRemaining(
                        child: _EmptyState(),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: _StressChart(entries: entries),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Row(
                            children: [
                              Text('Recent Check-ins',
                                  style: AppTheme.titleLarge),
                              const Spacer(),
                              Text(
                                '${entries.length} sessions',
                                style: AppTheme.labelSmall
                                    .copyWith(color: AppTheme.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) =>
                                _HistoryCard(entry: entries[i], index: i),
                            childCount: entries.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    HistoryProvider provider,
    List<HistoryEntry> entries,
  ) {
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
      title: Text('Mood Journey', style: AppTheme.titleLarge),
      centerTitle: true,
      actions: [
        if (entries.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.textSecondary),
            tooltip: 'Clear history',
            onPressed: () => _showClearDialog(context, provider),
          ),
      ],
    );
  }

  Future<void> _showClearDialog(
      BuildContext context, HistoryProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History?', style: AppTheme.titleLarge),
        content: Text(
          'All your check-in records will be deleted.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.clear();
  }
}

// ── Stress Chart ──────────────────────────────────────────────────────────
class _StressChart extends StatelessWidget {
  final List<HistoryEntry> entries;
  const _StressChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final recent = entries.take(10).toList().reversed.toList();
    final avg = entries.isNotEmpty
        ? entries.map((e) => e.stressLevel).reduce((a, b) => a + b) /
            entries.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.secondary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Stress Trend', style: AppTheme.titleLarge.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _avgColor(avg).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _avgColor(avg).withOpacity(0.4)),
                ),
                child: Text(
                  'Avg ${avg.toStringAsFixed(1)}/10',
                  style: AppTheme.labelSmall
                      .copyWith(color: _avgColor(avg), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 90,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(entries: recent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last ${recent.length} check-ins',
            style: AppTheme.labelSmall
                .copyWith(color: AppTheme.textSecondary.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Color _avgColor(double avg) {
    if (avg >= 8) return AppTheme.danger;
    if (avg >= 5) return AppTheme.primary;
    if (avg >= 3) return const Color(0xFFFFD166);
    return AppTheme.success;
  }
}

class _ChartPainter extends CustomPainter {
  final List<HistoryEntry> entries;
  _ChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final barWidth = size.width / (entries.length * 1.5);
    final spacing = barWidth * 0.5;
    final maxH = size.height;

    for (int i = 0; i < entries.length; i++) {
      final level = entries[i].stressLevel;
      final barH = (level / 10) * maxH;
      final x = i * (barWidth + spacing);
      final color = _colorForStress(level);

      // Bar background (ghost)
      final bg = Paint()
        ..color = AppTheme.surfaceLight
        ..style = PaintingStyle.fill;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, maxH),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, bg);

      // Filled bar
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final filled = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, maxH - barH, barWidth, barH),
        const Radius.circular(6),
      );
      canvas.drawRRect(filled, fill);
    }
  }

  Color _colorForStress(int level) {
    if (level >= 8) return AppTheme.danger;
    if (level >= 5) return AppTheme.primary;
    if (level >= 3) return const Color(0xFFFFD166);
    return AppTheme.success;
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.entries.length != entries.length;
}

// ── History Card ──────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final int index;

  const _HistoryCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final stressColor = _stressColor(entry.stressLevel);
    final emotionEmoji = _emotionEmoji(entry.primaryEmotion);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stressColor.withOpacity(0.25), width: 1),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        childrenPadding:
            const EdgeInsets.fromLTRB(18, 0, 18, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: stressColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stressColor.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(emotionEmoji,
                style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          _capitalise(entry.primaryEmotion),
          style: AppTheme.titleLarge.copyWith(
              fontSize: 15, color: AppTheme.textPrimary),
        ),
        subtitle: Text(
          _formatDate(entry.date),
          style:
              AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stressColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: stressColor.withOpacity(0.3)),
              ),
              child: Text(
                '${entry.stressLevel}/10',
                style: AppTheme.labelSmall.copyWith(
                    color: stressColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        iconColor: AppTheme.textSecondary,
        collapsedIconColor: AppTheme.textSecondary,
        children: [
          if (entry.raagaName != null) ...[
            _infoRow('🎵', 'Raaga', entry.raagaName!),
            const SizedBox(height: 8),
          ],
          if (entry.niti != null && entry.niti!.isNotEmpty) ...[
            const Divider(color: AppTheme.surfaceLight),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🪷',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"${entry.niti}"',
                    style: AppTheme.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text('$label: ',
            style:
                AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
        Text(value,
            style: AppTheme.bodyMedium
                .copyWith(color: AppTheme.textPrimary)),
      ],
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌿', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        Text('No journeys yet', style: AppTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          'Complete your first check-in\nto start tracking your wellness journey.',
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/checkin'),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppTheme.saffronGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '✨  Begin Check-in',
              style: AppTheme.titleLarge
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
