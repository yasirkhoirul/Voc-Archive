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
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    return await (() async {
      return await _datasource.getAllProducts();
    })().guard();
  }

  @override
  Future<Either<Failure, List<Product>>> getDiscountProducts() async {
    return await (() async {
      return await _datasource.getDiscountProducts();
    })().guard();
  }
  
  @override
  Future<Either<Failure, Product>> getProductById(String uid) async{
    return await (() async {
      return await _datasource.getProductById(uid);
    })().guard();
  }
}
