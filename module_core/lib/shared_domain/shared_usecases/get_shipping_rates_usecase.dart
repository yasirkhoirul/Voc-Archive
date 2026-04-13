import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../shared_repositories/shared_settings_repository.dart';

class GetShippingRatesUsecase {
  final SharedSettingsRepository _repository;
  GetShippingRatesUsecase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getShippingRates();
  }
}
