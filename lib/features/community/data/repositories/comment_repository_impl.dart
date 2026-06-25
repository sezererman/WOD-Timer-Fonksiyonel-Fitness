import '../../../../core/error/exceptions.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommentEntity>> getComments({
    required String workoutId,
    required int limit,
    required int offset,
  }) async {
    try {
      return await remoteDataSource.getComments(
        workoutId: workoutId,
        limit: limit,
        offset: offset,
      );
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Yorumlar getirilirken bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment({
    required String workoutId,
    required String text,
  }) async {
    try {
      await remoteDataSource.addComment(workoutId: workoutId, text: text);
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Yorum eklenirken bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Yorum silinirken bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> reportComment(String commentId, String reason) async {
    try {
      await remoteDataSource.reportComment(commentId, reason);
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Yorum raporlanırken bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }
}
