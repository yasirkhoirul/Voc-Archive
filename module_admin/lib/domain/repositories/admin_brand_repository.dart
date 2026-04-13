import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';

abstract class AdminBrandRepository {
  Future<Either<Failure, void>> createBrand(String nama);
  Future<Either<Failure, void>> updateBrand(String uid, String nama);
  Future<Either<Failure, void>> deleteBrand(String uid);
}
