import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../core/routing/route_constants.dart';

import '../../../community/domain/entities/workout_share_entity.dart';
import '../../../community/presentation/widgets/feed_post_card.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';
import '../../../workout_modes/presentation/pages/mode_config_page.dart';
import '../../../leveling/presentation/bloc/level_bloc.dart';
import '../../../leveling/presentation/bloc/level_event.dart';
import '../../../leveling/presentation/bloc/level_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header_widget.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../community/domain/entities/comment_entity.dart';

class ProfilePageConstants {
  static const String guestTitle = 'Antrenmanlarını Kaydet ve Topluluğa Katıl!';
  static const String guestSubtitle =
      'Gelişimini takip etmek, seviye atlamak ve diğer sporcuların antrenmanlarını görmek için hemen ücretsiz bir hesap oluştur.';
  static const String guestSignUpButton = 'Hemen Üye Ol';
  static const String guestLoginButton = 'Zaten hesabın var mı? Giriş Yap';
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Sadece oturum açmış kullanıcılar için ProfileBloc ve LevelBloc oluşturulur.
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => sl<ProfileBloc>()..add(LoadProfileData(state.user.id)),
              ),
              BlocProvider(
                create: (context) => sl<LevelBloc>()..add(LevelStarted(state.user.id)),
              ),
            ],
            child: const UserProfileView(),
          );
        }
        return const GuestProfileView();
      },
    );
  }
}

class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CrossFit temasına uygun ikon (Dikkat çekici neon renk)
              const Icon(
                Icons.sports_gymnastics_rounded,
                size: 100,
                color: AppColors.secondary, // Cyan rengi neon etkisi yaratır
              ),
              const SizedBox(height: 32),
              
              const Text(
                ProfilePageConstants.guestTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                ProfilePageConstants.guestSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(Routes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary, // Neon Yeşil/Cyan etkisi
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shadowColor: AppColors.secondary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    ProfilePageConstants.guestSignUpButton,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => context.push(Routes.login),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textHint,
                ),
                child: const Text(
                  ProfilePageConstants.guestLoginButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Aşağıdakiler daha önce tasarlanan gerçek profil istatistiklerini (UserProfileView) içeriyor
class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('${Routes.profile}/settings'),
          ),
        ],
      ),
      body: _buildAuthenticatedBody(context, theme),
    );
  }

  Widget _buildAuthenticatedBody(BuildContext context, ThemeData theme) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const _ProfileShimmer();
        }

        if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is Authenticated) {
                          context.read<ProfileBloc>().add(LoadProfileData(authState.user.id));
                        }
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthSignOutRequested());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (state is ProfileLoaded) {
          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: BlocBuilder<LevelBloc, LevelState>(
                      builder: (context, levelState) {
                        final currentLevel = levelState is LevelLoaded
                            ? levelState.level
                            : 0;
                        return ProfileHeaderWidget(
                          profile: state.userProfile,
                          profileState: state,
                          currentLevel: currentLevel,
                        );
                      },
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        indicatorColor: Colors.amber,
                        labelColor: Colors.amber,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Paylaşımlarım'),
                          Tab(text: 'Yorumlarım'),
                          Tab(text: 'Beğendiklerim'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _WorkoutsList(workouts: state.sharedWorkouts),
                  _CommentsList(comments: state.userComments),
                  _WorkoutsList(workouts: state.likedWorkouts),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────


class _WorkoutsList extends StatelessWidget {
  final List<WorkoutShareEntity> workouts;

  const _WorkoutsList({required this.workouts});

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Center(
        child: Text(
          'Henüz buralar ıssız...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FeedPostCard(
            post: workout,
            onCommentTap: () {},
            onReDoTap: () {
              final mode = WorkoutModeX.fromString(workout.workoutType);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ModeConfigPage(mode: mode),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CommentsList extends StatelessWidget {
  final List<CommentEntity> comments;

  const _CommentsList({required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text(
          'Henüz yorum yapmadın.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              comment.workoutTitle ?? 'Bir Antrenman',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                comment.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProfileShimmer extends StatefulWidget {
  const _ProfileShimmer();

  @override
  State<_ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<_ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_controller.value * 0.5),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              Container(width: 150, height: 20, color: Colors.grey),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => Container(width: 60, height: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.all(16),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
