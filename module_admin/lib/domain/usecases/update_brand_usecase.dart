import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_brand_repository.dart';

class UpdateBrandUsecase {
  final AdminBrandRepository _repository;
  UpdateBrandUsecase(this._repository);

  Future<Either<Failure, void>> call(String uid, String nama) {
    return _repository.updateBrand(uid, nama);
  }
}
