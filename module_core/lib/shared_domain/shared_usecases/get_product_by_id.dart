import 'package:dartz/dartz.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';
import 'package:module_core/shared_domain/shared_repositories/shared_product_repository.dart';
import 'package:module_core/utils/failure.dart';

class GetProductById {
  final SharedProductRepository _repository;

  GetProductById(this._repository);

  Future<Either<Failure, Product>> call(String uid) async {
    return await _repository.getProductById(uid);
  }
}