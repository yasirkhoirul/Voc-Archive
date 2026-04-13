import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../shared_repositories/shared_brand_repository.dart';

class GetBrandsUsecase {
  final SharedBrandRepository _repository;
  GetBrandsUsecase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getBrands();
  }
}
