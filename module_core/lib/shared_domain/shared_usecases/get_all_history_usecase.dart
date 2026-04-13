import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../shared_entities/order_history.dart';
import '../shared_repositories/shared_history_repository.dart';

class GetAllHistoryUseCase {
  final SharedHistoryRepository repository;

  GetAllHistoryUseCase(this.repository);

  Future<Either<Failure, List<OrderHistoryEntity>>> call() {
    return repository.getAllHistory();
  }
}
