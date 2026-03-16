import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../shared_entities/product.dart';

abstract class SharedProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, List<Product>>> getDiscountProducts();
  Future<Either<Failure, Product>> getProductById(String uid);
}
