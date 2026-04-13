import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';

abstract class SharedBrandRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getBrands();
}
