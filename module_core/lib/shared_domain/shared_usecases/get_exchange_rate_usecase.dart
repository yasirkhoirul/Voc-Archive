import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../shared_repositories/shared_settings_repository.dart';

class GetExchangeRateUsecase {
  final SharedSettingsRepository _repository;
  GetExchangeRateUsecase(this._repository);

  Future<Either<Failure, double?>> call() {
    return _repository.getExchangeRate();
  }
}
