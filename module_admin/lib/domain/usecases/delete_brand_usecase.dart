import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_brand_repository.dart';

class DeleteBrandUsecase {
  final AdminBrandRepository _repository;
  DeleteBrandUsecase(this._repository);

  Future<Either<Failure, void>> call(String uid) {
    return _repository.deleteBrand(uid);
  }
}
