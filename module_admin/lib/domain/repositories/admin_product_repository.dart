import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/create_product_input.dart';

abstract class AdminProductRepository {
  Future<Either<Failure, void>> createProduct(CreateProductInput input);
  Future<Either<Failure, void>> updateProduct(CreateProductInput input);
}
