import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';

// Utility untuk Repository (menangkap error dan mengembalikan Either)
extension FutureRepoExt<T> on Future<T> {
  Future<Either<Failure, T>> guard() async {
    try {
      final result = await this;
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

extension FutureDatasourceExt<T> on Future<T> {
  Future<T> guardDatasource() async {
    try {
      return await this;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}