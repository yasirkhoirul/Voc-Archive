import 'package:dartz/dartz.dart';
import '../../utils/failure.dart';
import '../../utils/runcatching.dart';
import '../../shared_domain/shared_entities/product.dart';
import '../../shared_domain/shared_repositories/shared_product_repository.dart';
import '../datasources/shared_product_datasource.dart';

class SharedProductRepositoryImpl implements SharedProductRepository {
  final SharedProductDatasource _datasource;

  SharedProductRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Product>>> getAllProducts({
    String? query,
    List<String>? types,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await (() async {
      return await _datasource.getAllProducts(
        query: query,
        types: types,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    })().guard();
  }

  @override
  Future<Either<Failure, List<Product>>> getDiscountProducts({
    String? query,
  }) async {
    return await (() async {
      return await _datasource.getDiscountProducts(query: query);
    })().guard();
  }

  @override
  Future<Either<Failure, Product>> getProductById(String uid) async {
    return await (() async {
      return await _datasource.getProductById(uid);
    })().guard();
  }
}
