import 'package:dartz/dartz.dart';
import '../../shared_domain/shared_entities/order_history.dart';
import '../../shared_domain/shared_repositories/shared_history_repository.dart';
import '../../utils/failure.dart';
import '../datasources/shared_history_remote_datasource.dart';

class SharedHistoryRepositoryImpl implements SharedHistoryRepository {
  final SharedHistoryRemoteDataSource remoteDataSource;

  SharedHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> getAllHistory() async {
    try {
      final result = await remoteDataSource.getAllHistory();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> getHistoryByUserId(String userId) async {
    try {
      final result = await remoteDataSource.getHistoryByUserId(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
