import 'package:dartz/dartz.dart';
import '../entities/create_product_input.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_product_repository.dart';

class CreateProductUseCase {
  final AdminProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<Either<Failure, void>> call(CreateProductInput input) {
    return _repository.createProduct(input);
  }
}
