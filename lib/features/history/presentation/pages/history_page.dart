import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../design_system/constants/app_strings.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../domain/entities/workout_record.dart';

/// Antrenman geçmişi sayfası.
///
/// PERFORMANS: StatefulWidget'a dönüştürüldü.
/// initState'te tek seferlik HistoryLoaded event'i → build() saf ve yan etkisiz.
/// Önceki pattern: Her rebuild'de (tema, orientation, parent state değişimi)
/// Hive sorgusu yapılıyordu.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Sayfa mount edildiğinde bir kez çalışır — build() her tetiklendiğinde değil.
    context.read<HistoryBloc>().add(const HistoryLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  AppStrings.history,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      if (state is HistoryLoadSuccess) {
                        if (state.records.isEmpty) {
                          return const _EmptyHistoryView();
                        }
                        return _HistoryListView(state: state);
                      }
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Boş Durum
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            AppStrings.noHistory,
            style: TextStyle(fontSize: 16, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Liste Görünümü
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryListView extends StatelessWidget {
  final HistoryLoadSuccess state;

  const _HistoryListView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Özet kartları
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatCard(
                icon: Icons.sports_score_rounded,
                label: 'TOPLAM',
                value: '${state.stats.totalWorkouts}',
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: Icons.calendar_view_week_rounded,
                label: 'BU HAFTA',
                value: '${state.stats.weeklyWorkouts}',
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: Icons.calendar_month_rounded,
                label: 'BU AY',
                value: '${state.stats.monthlyWorkouts}',
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: Icons.access_time_rounded,
                label: 'TOPLAM SÜRE',
                value: DurationFormatter.format(state.stats.totalSeconds),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'SON ANTRENMANLAR',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.records.length,
            itemBuilder: (context, index) {
              final record = state.records[index];
              // Ayrı widget: Flutter diffing verimli çalışır,
              // yüzlerce kayıtta scroll jank olmaz.
              return _HistoryListItem(
                key: ValueKey(record.id),
                record: record,
                onDismiss: () => context
                    .read<HistoryBloc>()
                    .add(HistoryWorkoutDeleted(record.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Liste Öğesi — Ayrı Widget (önceden inline'dı)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryListItem extends StatelessWidget {
  final WorkoutRecord record;
  final VoidCallback onDismiss;

  // PERFORMANS: static const — scroll sırasında sıfır allokasyon.
  // Her rebuild'de yeni List + BoxShadow + Color oluşturulmaz.
  static const _cardShadow = [
    BoxShadow(
      color: Color(0x33000000), // Colors.black @ %20 opacity
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  const _HistoryListItem({
    super.key,
    required this.record,
    required this.onDismiss,
  });

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}'
        '.${date.month.toString().padLeft(2, '0')}'
        '.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
          boxShadow: _cardShadow, // static const — sıfır allokasyon
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.modeName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        DurationFormatter.format(record.totalSeconds),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${record.rounds} Tur',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TAMAMLANDI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// İstatistik Kartı
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  // PERFORMANS: static const gradient — her scroll/rebuild'de sıfır allokasyon.
  static const _gradient = LinearGradient(
    colors: [AppColors.surfaceLight, AppColors.surface],
  );

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // Expanded widget'ı DIŞARIDA — widget reusable ve herhangi bir layout'ta kullanılabilir
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _gradient, // static const — sıfır allokasyon
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ],
      ),
    );
  }
}
