import 'package:dartz/dartz.dart';
import 'package:module_admin/domain/entities/create_product_input.dart';
import 'package:module_admin/domain/repositories/admin_product_repository.dart';
import 'package:module_core/utils/failure.dart';

class UpdateProductUsecase {
  final AdminProductRepository _repository;
  const UpdateProductUsecase(this._repository);
  Future<Either<Failure, void>> call(CreateProductInput input) {
    return _repository.updateProduct(input);
  }
}