import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_brand_repository.dart';

class CreateBrandUsecase {
  final AdminBrandRepository _repository;
  CreateBrandUsecase(this._repository);

  Future<Either<Failure, void>> call(String nama) {
    return _repository.createBrand(nama);
  }
}
