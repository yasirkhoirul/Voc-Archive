import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';

abstract class SharedSettingsRepository {
  Future<Either<Failure, double?>> getExchangeRate();
  Future<Either<Failure, List<Map<String, dynamic>>>> getShippingRates();
}

