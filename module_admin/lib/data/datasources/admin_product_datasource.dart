import 'package:cloud_functions/cloud_functions.dart';
import '../models/create_product_input_model.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class AdminProductDatasource {
  Future<void> createProduct(CreateProductInputModel input);
  Future<void> updateProduct(CreateProductInputModel input);
}

class AdminProductDatasourceImpl implements AdminProductDatasource {
  final FirebaseFunctions _functions;

  AdminProductDatasourceImpl(this._functions);

  @override
  Future<void> createProduct(CreateProductInputModel input) async {
    return await (() async {
      final callable = _functions.httpsCallable('createProduct');
      await callable.call(input.toJson());
    })().guardDatasource();
  }
  
  @override
  Future<void> updateProduct(CreateProductInputModel input) async{
    return await (() async {
      final callable = _functions.httpsCallable('updateProduct');
      await callable.call(input.toJson());
    })().guardDatasource();
  }
}
