import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../bloc/workout_share/workout_share_bloc.dart';
import '../bloc/workout_share/workout_share_event.dart';
import '../bloc/workout_share/workout_share_state.dart';
import '../widgets/feed_post_card.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_constants.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WorkoutShareBloc>().add(FetchSharedWorkoutsEvent());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Pagination: Gelecekte FetchMoreWorkoutsEvent eklenecek
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANS: BlocSelector — yalnızca userId değişince rebuild.
    // context.watch<AuthBloc>() her AuthBloc state emitinde rebuild yapardı
    // (token refresh, session güncelleme vb.). BlocSelector bunu önler.
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state) => state is Authenticated ? state.user.id : null,
      builder: (context, currentUserId) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'COMMUNITY',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: GradientBackground(
            child: SafeArea(
              child: currentUserId == null 
                ? _buildGuestView(context)
                : BlocConsumer<WorkoutShareBloc, WorkoutShareState>(
                listener: (context, state) {
                  if (state is WorkoutShareOptimisticError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is WorkoutShareLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is WorkoutShareError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  if (state is WorkoutShareLoaded) {
                    if (state.posts.isEmpty) {
                      return const Center(
                        child: Text(
                          'Henüz bir paylaşım yok.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context
                            .read<WorkoutShareBloc>()
                            .add(FetchSharedWorkoutsEvent());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        itemCount: state.posts.length,
                        addAutomaticKeepAlives: false,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          // Her kart kendi StatefulWidget'ı — Stream bağlantıları
                          // kart yaşadığı sürece tek kalır, dispose'da kapanır.
                          return FeedPostCard(
                            key: ValueKey(post.id), // Stabil key — rebuild optimizasyonu
                            post: post,
                            currentUserId: currentUserId,
                            onCommentTap: () {
                              // TODO: Yorum Sayfasına/Modalına Geçiş
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          floatingActionButton: currentUserId == null ? null : FloatingActionButton.extended(
            onPressed: () async {
              final result = await context.push(Routes.shareWorkout);
              if (result == true && context.mounted) {
                // Eğer paylaşım başarılı olursa akışı yenile
                context.read<WorkoutShareBloc>().add(FetchSharedWorkoutsEvent());
              }
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('Antrenman Paylaş', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'Topluluğa Katıl',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Antrenmanlarını paylaşmak ve diğer sporcuları görmek için giriş yapmalısın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.push(Routes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Giriş Yap', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push(Routes.register),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hesap Oluştur', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
