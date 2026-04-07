import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../shared_entities/product.dart';
import '../shared_repositories/shared_product_repository.dart';

class GetDiscountProductsUseCase {
  final SharedProductRepository _repository;

  GetDiscountProductsUseCase(this._repository);

  Future<Either<Failure, List<Product>>> call() {
    return _repository.getDiscountProducts();
  }
}
