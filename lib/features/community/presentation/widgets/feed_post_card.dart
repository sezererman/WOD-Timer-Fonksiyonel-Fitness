import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../features/leveling/presentation/widgets/tier_badge_widget.dart';
import '../bloc/workout_share/workout_share_bloc.dart';
import '../bloc/workout_share/workout_share_event.dart';
import '../../data/datasources/supabase_social_datasource.dart';
import '../../domain/entities/workout_share_entity.dart';
import 'feed_glass_card.dart';

// ─── Sabit değerler (Magic Number'dan arındırılmış) ────────────────────────
const _kCardBottomPadding   = EdgeInsets.only(bottom: 20.0);
const _kSectionGap          = SizedBox(height: 20);
const _kNoteGap             = SizedBox(height: 16);
const _kRedoGap             = SizedBox(height: 12);
const _kFooterGap           = SizedBox(height: 8);
const _kInteractionSpacing  = SizedBox(width: 12);
const _kAvatarIconSize      = 48.0;
const _kWorkoutTypeSize     = 24.0;
const _kDurationTextSize    = 16.0;
const _kNoteTextSize        = 14.0;
const _kTimeTextSize        = 12.0;
const _kRedoIconSize        = 16.0;
const _kUnknownUserPrefix   = 'Athlete ';
const _kUnknownUserIdLength = 4;

/// Her feed kartı kendi StatefulWidget'ı — Stream'ler initState'te tek sefer
/// oluşturulur ve dispose'da otomatik kapanır. Bu sayede ListView.builder her
/// yeniden build ettiğinde yeni WebSocket bağlantısı açılmaz (Memory Leak önleme).
///
/// MİMARİ NOT: _likesStream ve _commentsStream burada geçici olarak
/// SupabaseSocialDataSource'tan alınmaktadır. İleride bir SocialBloc/Cubit
/// aracılığıyla sağlanmalı; UI katmanı data source'a doğrudan erişmemeli.
class FeedPostCard extends StatefulWidget {
  final WorkoutShareEntity post;
  final String? currentUserId;
  final VoidCallback? onCommentTap;
  final VoidCallback? onReDoTap;
  final VoidCallback? onShareTap;

  const FeedPostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.onCommentTap,
    this.onReDoTap,
    this.onShareTap,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  // Stream'ler YALNIZCA BİR KEZ oluşturulur — build her çağrıldığında yeniden oluşturulmaz.
  late final Stream<List<Map<String, dynamic>>> _likesStream;
  late final Stream<List<Map<String, dynamic>>> _commentsStream;

  @override
  void initState() {
    super.initState();
    final dataSource = sl<SupabaseSocialDataSource>();
    _likesStream    = dataSource.listenToLikes(widget.post.id);
    _commentsStream = dataSource.listenToComments(widget.post.id);
  }

  String get _displayName =>
      widget.post.userName ??
      '$_kUnknownUserPrefix${widget.post.userId.substring(0, _kUnknownUserIdLength)}';

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24)   return '${diff.inHours}sa önce';
    return '${diff.inDays}g önce';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kCardBottomPadding,
      child: FeedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _kSectionGap,
            _buildBody(),
            if (widget.post.notes?.isNotEmpty == true) ...[
              _kNoteGap,
              Text(
                widget.post.notes!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: _kNoteTextSize,
                ),
              ),
            ],
            if (widget.onReDoTap != null) ...[
              _kRedoGap,
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: widget.onReDoTap,
                  icon: const Icon(Icons.refresh_rounded, size: _kRedoIconSize),
                  label: const Text(
                    'Yeniden Yap',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
            _kSectionGap,
            const Divider(color: Colors.white10),
            _kFooterGap,
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar + tier rozeti (sağ alt köşeye konumlanmış)
        TieredAvatar(
          avatarUrl: widget.post.userAvatarUrl,
          displayName: _displayName,
          level: widget.post.userLevel,
          radius: _kAvatarIconSize / 2,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: _kDurationTextSize,
                ),
              ),
              // Tier badge satırı — level varsa göster
              if (widget.post.userLevel != null) ...[
                const SizedBox(height: 4),
                TierBadgeRow(level: widget.post.userLevel!),
              ],
            ],
          ),
        ),
        Text(
          _timeAgo(widget.post.date),
          style: const TextStyle(color: Colors.white54, fontSize: _kTimeTextSize),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.workoutType.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Orbitron',
                color: AppColors.primary,
                fontSize: _kWorkoutTypeSize,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DurationFormatter.format(widget.post.durationSeconds)} • ${widget.post.score ?? 0} Skor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: _kDurationTextSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Icon(Icons.fitness_center_rounded, color: Colors.white24, size: _kAvatarIconSize),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Beğeni Stream — tek bağlantı, dispose'da kapanır
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _likesStream,
          builder: (context, snapshot) {
            int  likesCount  = widget.post.likesCount;
            bool isLikedByMe = widget.currentUserId != null &&
                widget.post.likedUserIds.contains(widget.currentUserId);

            if (snapshot.hasData) {
              final likesList = snapshot.data!;
              likesCount  = likesList.length;
              isLikedByMe = likesList.any(
                (like) => like['user_id'] == widget.currentUserId,
              );
            }

            return _InteractionButton(
              icon: isLikedByMe ? Icons.fitness_center : Icons.fitness_center_outlined,
              label: '$likesCount',
              isActive: isLikedByMe,
              onTap: widget.currentUserId == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      context.read<WorkoutShareBloc>().add(
                            ToggleLikeEvent(
                              workoutId: widget.post.id,
                              currentUserId: widget.currentUserId!,
                            ),
                          );
                    },
            );
          },
        ),
        _kInteractionSpacing,
        // Yorum Stream — tek bağlantı, dispose'da kapanır
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _commentsStream,
          builder: (context, snapshot) {
            final commentsCount = snapshot.hasData ? snapshot.data!.length : 0;
            return _InteractionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: '$commentsCount',
              onTap: widget.onCommentTap,
            );
          },
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white54),
          onPressed: widget.onShareTap,
        ),
      ],
    );
  }
}

// ─── Yardımcı Widget: Beğeni ve Yorum butonları için DRY yapısı ─────────────

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : Colors.white54;
    return Row(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
