import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../../shared_domain/shared_entities/order_history.dart';

abstract class SharedHistoryRepository {
  Future<Either<Failure, List<OrderHistoryEntity>>> getAllHistory();
  Future<Either<Failure, List<OrderHistoryEntity>>> getHistoryByUserId(String userId);
}
