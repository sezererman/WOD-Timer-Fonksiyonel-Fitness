import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class GetCommentsParams {
  final String workoutId;
  final int limit;
  final int offset;

  GetCommentsParams({
    required this.workoutId,
    required this.limit,
    required this.offset,
  });
}

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call(GetCommentsParams params) {
    return repository.getComments(
      workoutId: params.workoutId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
