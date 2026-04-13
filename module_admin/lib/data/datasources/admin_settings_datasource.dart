import 'package:cloud_functions/cloud_functions.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class AdminSettingsDatasource {
  Future<void> setExchangeRate(double usdToIdr);
  Future<void> addShippingRate(String namaArea, double harga);
  Future<void> updateShippingRate(String namaArea, double harga);
  Future<void> deleteShippingRate(String namaArea);
}

class AdminSettingsDatasourceImpl implements AdminSettingsDatasource {
  final FirebaseFunctions _functions;

  AdminSettingsDatasourceImpl(this._functions);

  @override
  Future<void> setExchangeRate(double usdToIdr) async {
    return await (() async {
      final callable = _functions.httpsCallable('setExchangeRate');
      await callable.call({'usd_to_idr': usdToIdr});
    })().guardDatasource();
  }

  @override
  Future<void> addShippingRate(String namaArea, double harga) async {
    return await (() async {
      final callable = _functions.httpsCallable('addShippingRate');
      await callable.call({'nama_area': namaArea, 'harga': harga});
    })().guardDatasource();
  }

  @override
  Future<void> updateShippingRate(String namaArea, double harga) async {
    return await (() async {
      final callable = _functions.httpsCallable('updateShippingRate');
      await callable.call({'nama_area': namaArea, 'harga': harga});
    })().guardDatasource();
  }

  @override
  Future<void> deleteShippingRate(String namaArea) async {
    return await (() async {
      final callable = _functions.httpsCallable('deleteShippingRate');
      await callable.call({'nama_area': namaArea});
    })().guardDatasource();
  }
}
