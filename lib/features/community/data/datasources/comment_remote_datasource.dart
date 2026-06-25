import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments({
    required String workoutId,
    required int limit,
    required int offset,
  });

  Future<void> addComment({
    required String workoutId,
    required String text,
  });

  Future<void> deleteComment(String commentId);

  Future<void> reportComment(String commentId, String reason);
}
