import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../shared_entities/order_history.dart';
import '../shared_repositories/shared_history_repository.dart';

class GetHistoryByUserIdUseCase {
  final SharedHistoryRepository repository;

  GetHistoryByUserIdUseCase(this.repository);

  Future<Either<Failure, List<OrderHistoryEntity>>> call(String userId) {
    return repository.getHistoryByUserId(userId);
  }
}
