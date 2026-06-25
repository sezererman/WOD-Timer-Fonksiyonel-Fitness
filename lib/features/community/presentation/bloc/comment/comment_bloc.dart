import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/sanitization_utils.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../../../domain/usecases/get_comments_usecase.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CommentRepository repository;
  final SupabaseClient supabaseClient;

  static const int _limit = 10;

  CommentBloc({
    required this.getCommentsUseCase,
    required this.repository,
    required this.supabaseClient,
  }) : super(CommentInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<LoadMoreCommentsEvent>(_onLoadMoreComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ReportCommentEvent>(_onReportComment);
  }

  Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    try {
      final comments = await getCommentsUseCase(
        GetCommentsParams(workoutId: event.workoutId, limit: _limit, offset: 0),
      );
      emit(CommentLoaded(
        comments: comments,
        hasReachedMax: comments.length < _limit,
      ));
    } catch (e) {
      emit(const CommentError('Yorumlar yüklenemedi.'));
    }
  }

  Future<void> _onLoadMoreComments(LoadMoreCommentsEvent event, Emitter<CommentState> emit) async {
    if (state is! CommentLoaded) return;
    final currentState = state as CommentLoaded;
    if (currentState.hasReachedMax || currentState.isPaginating) return;

    emit(currentState.copyWith(isPaginating: true));
    try {
      final newComments = await getCommentsUseCase(
        GetCommentsParams(
          workoutId: event.workoutId,
          limit: _limit,
          offset: currentState.comments.length,
        ),
      );

      if (newComments.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isPaginating: false));
      } else {
        emit(currentState.copyWith(
          comments: List.of(currentState.comments)..addAll(newComments),
          hasReachedMax: newComments.length < _limit,
          isPaginating: false,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isPaginating: false));
      // Optionally emit a temporary error state
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<CommentState> emit) async {
    try {
      // 1. Sanitization: XSS ve Emoji kontrolü
      final cleanText = SanitizationUtils.sanitizeComment(event.text);
      if (cleanText.isEmpty) {
        emit(const CommentActionError('Yorum boş olamaz veya geçersiz karakterler içeriyor.'));
        return;
      }

      await repository.addComment(workoutId: event.workoutId, text: cleanText);
      emit(const CommentActionSuccess('Yorum başarıyla eklendi.'));
      
      // Yorum eklendikten sonra listeyi yenile (veya local'e ekle)
      add(LoadCommentsEvent(event.workoutId));
    } catch (e) {
      emit(const CommentActionError('Yorum eklenirken hata oluştu.'));
    }
  }

  Future<void> _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // 2. Authorization: Yalnızca kendi yorumunu silebilir
      if (currentUser.id != event.commentUserId) {
        emit(const CommentActionError('Yetkiniz yok: Yalnızca kendi yorumunuzu silebilirsiniz.'));
        return;
      }

      await repository.deleteComment(event.commentId);
      emit(const CommentActionSuccess('Yorum silindi.'));

      // Sildikten sonra güncel state'i oluştur
      if (state is CommentLoaded) {
        final currentState = state as CommentLoaded;
        final updatedList = currentState.comments.where((c) => c.id != event.commentId).toList();
        emit(currentState.copyWith(comments: updatedList));
      }
    } catch (e) {
      emit(const CommentActionError('Yorum silinirken hata oluştu.'));
    }
  }

  Future<void> _onReportComment(ReportCommentEvent event, Emitter<CommentState> emit) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // 3. Authorization: Sadece BAŞKASININ yorumu raporlanabilir
      if (currentUser.id == event.commentUserId) {
        emit(const CommentActionError('Kendi yorumunuzu raporlayamazsınız.'));
        return;
      }

      await repository.reportComment(event.commentId, event.reason);
      emit(const CommentActionSuccess('Yorum inceleme için raporlandı.'));
    } catch (e) {
      emit(const CommentActionError('Raporlama sırasında hata oluştu.'));
    }
  }
}
