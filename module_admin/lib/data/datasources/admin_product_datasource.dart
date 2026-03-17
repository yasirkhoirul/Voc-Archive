import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/web.dart';
import '../models/create_product_input_model.dart';
import '../models/update_product_input_model.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class AdminProductDatasource {
  Future<void> createProduct(CreateProductInputModel input);
  Future<void> updateProduct(UpdateProductInputModel input);
  Future<void> deleteProduct(String uid);
}

class AdminProductDatasourceImpl implements AdminProductDatasource {
  final FirebaseFunctions _functions;

  AdminProductDatasourceImpl(this._functions);

  @override
  Future<void> createProduct(CreateProductInputModel input) async {
    return await (() async {
      final callable = _functions.httpsCallable('createProduct');
      final response = await callable.call(input.toJson());
      return response.data;
    })().guardDatasource();
  }
  
  @override
  Future<void> updateProduct(UpdateProductInputModel input) async{
    return await (() async {
      final callable = _functions.httpsCallable('updateProduct');
      final response = await callable.call(input.toJson());
      Logger().d('Update Product Response: ${response.data}');
      return response.data;
    })().guardDatasource();
  }
  
  @override
  Future<void> deleteProduct(String uid) async{
    return await (() async {
      await _functions.httpsCallable('deleteProduct').call({'uid': uid});
    })().guardDatasource();
  }
}
