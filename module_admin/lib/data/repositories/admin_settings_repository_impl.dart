import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../datasources/admin_settings_datasource.dart';
import '../../domain/repositories/admin_settings_repository.dart';
import 'package:module_core/utils/runcatching.dart';

class AdminSettingsRepositoryImpl implements AdminSettingsRepository {
  final AdminSettingsDatasource _datasource;

  AdminSettingsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> setExchangeRate(double usdToIdr) async {
    return await _datasource.setExchangeRate(usdToIdr).guard();
  }

  @override
  Future<Either<Failure, void>> addShippingRate(
    String namaArea,
    double harga,
  ) async {
    return await _datasource.addShippingRate(namaArea, harga).guard();
  }

  @override
  Future<Either<Failure, void>> updateShippingRate(
    String namaArea,
    double harga,
  ) async {
    return await _datasource.updateShippingRate(namaArea, harga).guard();
  }

  @override
  Future<Either<Failure, void>> deleteShippingRate(String namaArea) async {
    return await _datasource.deleteShippingRate(namaArea).guard();
  }
}
