import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../core/routing/route_constants.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../timer/domain/entities/timer_config.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';
import '../../domain/entities/challenge.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Demo
    final dailyWod = Challenge(
      id: 'daily-1',
      date: DateTime.now(),
      title: '20 Min AMRAP - Cindy',
      mode: WorkoutMode.amrap,
      durationSeconds: 1200,
      rounds: 0,
      workSeconds: 1200,
      movements: const [
        '5 Pull-ups',
        '10 Push-ups',
        '15 Squats'
      ],
      likesCount: 1540,
    );

    final communityWods = [
      Challenge(
        id: 'comm-1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Murph Prep',
        mode: WorkoutMode.forTime,
        durationSeconds: 2400,
        workSeconds: 2400,
        movements: const ['1 Mile Run', '100 Pull-ups', '200 Push-ups', '300 Squats', '1 Mile Run'],
        likesCount: 890,
      ),
      Challenge(
        id: 'comm-2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Tabata Core',
        mode: WorkoutMode.tabata,
        durationSeconds: 240,
        rounds: 8,
        workSeconds: 20,
        restSeconds: 10,
        movements: const ['Hollow Rocks', 'V-Ups'],
        likesCount: 650,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Meydan Okumalar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Günün Antrenmanı (WOD)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _DailyWodCard(challenge: dailyWod),
            
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Topluluğun Seçimi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: communityWods.length,
                itemBuilder: (context, index) {
                  return _CommunityWodCard(challenge: communityWods[index]);
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DailyWodCard extends StatelessWidget {
  final Challenge challenge;

  const _DailyWodCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChallengeDetails(context, challenge),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDD2476).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern or Icon
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.local_fire_department,
                size: 180,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      challenge.mode.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        DurationFormatter.format(challenge.durationSeconds),
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite, color: Colors.white70, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${challenge.likesCount}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityWodCard extends StatelessWidget {
  final Challenge challenge;

  const _CommunityWodCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChallengeDetails(context, challenge),
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    challenge.mode.displayName,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.error, size: 16),
                      const SizedBox(width: 4),
                      Text('${challenge.likesCount}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                challenge.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DurationFormatter.format(challenge.durationSeconds),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showChallengeDetails(BuildContext context, Challenge challenge) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              challenge.mode.displayName.toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.title,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoBadge(Icons.timer_outlined, DurationFormatter.format(challenge.durationSeconds)),
                const SizedBox(width: 12),
                _buildInfoBadge(Icons.repeat, '${challenge.rounds} Tur'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Hareketler',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: challenge.movements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          challenge.movements[index].toString(),
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  _startChallengeTimer(context, challenge);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: const Text(
                  'MEYDAN OKUMAYI KABUL ET',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget _buildInfoBadge(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceLight.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

void _startChallengeTimer(BuildContext context, Challenge challenge) {
  final config = TimerConfig(
    mode: challenge.mode,
    rounds: challenge.rounds,
    workSeconds: challenge.workSeconds,
    restSeconds: challenge.restSeconds,
    prepareSeconds: challenge.prepareSeconds,
    cooldownSeconds: challenge.cooldownSeconds,
  );
  context.go('${Routes.timer}/active', extra: config);
}
