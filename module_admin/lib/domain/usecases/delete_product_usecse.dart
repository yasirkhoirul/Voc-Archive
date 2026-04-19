import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_product_repository.dart';

class DeleteProductUseCase {
  final AdminProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.deleteProduct(productId);
  }
}
