import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import 'package:module_core/utils/runcatching.dart';
import '../../shared_domain/shared_repositories/shared_settings_repository.dart';
import '../datasources/shared_settings_datasource.dart';

class SharedSettingsRepositoryImpl implements SharedSettingsRepository {
  final SharedSettingsDatasource _datasource;

  SharedSettingsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, double?>> getExchangeRate() async {
    return await _datasource.getExchangeRate().guard();
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getShippingRates() async {
    return await _datasource.getShippingRates().guard();
  }
}

