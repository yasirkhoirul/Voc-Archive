import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../shared_entities/product.dart';

abstract class SharedProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts({
    String? query,
    List<String>? types,
    double? minPrice,
    double? maxPrice,
  });
  Future<Either<Failure, List<Product>>> getDiscountProducts({String? query});
  Future<Either<Failure, Product>> getProductById(String uid);
}
