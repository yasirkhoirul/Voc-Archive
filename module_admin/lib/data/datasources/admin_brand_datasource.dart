import 'package:cloud_functions/cloud_functions.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class AdminBrandDatasource {
  Future<void> createBrand(String nama);
  Future<void> updateBrand(String uid, String nama);
  Future<void> deleteBrand(String uid);
}

class AdminBrandDatasourceImpl implements AdminBrandDatasource {
  final FirebaseFunctions _functions;

  AdminBrandDatasourceImpl(this._functions);

  @override
  Future<void> createBrand(String nama) async {
    return await (() async {
      final callable = _functions.httpsCallable('createBrand');
      await callable.call({'nama': nama});
    })().guardDatasource();
  }

  @override
  Future<void> updateBrand(String uid, String nama) async {
    return await (() async {
      final callable = _functions.httpsCallable('updateBrand');
      await callable.call({'uid': uid, 'nama': nama});
    })().guardDatasource();
  }

  @override
  Future<void> deleteBrand(String uid) async {
    return await (() async {
      await _functions.httpsCallable('deleteBrand').call({'uid': uid});
    })().guardDatasource();
  }
}
