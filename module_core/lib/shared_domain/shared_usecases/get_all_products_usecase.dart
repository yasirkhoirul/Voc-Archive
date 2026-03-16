import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../shared_entities/product.dart';
import '../shared_repositories/shared_product_repository.dart';

class GetAllProductsUseCase {
  final SharedProductRepository _repository;

  GetAllProductsUseCase(this._repository);

  Future<Either<Failure, List<Product>>> call() {
    return _repository.getAllProducts();
  }
}
