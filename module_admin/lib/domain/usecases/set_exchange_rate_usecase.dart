import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_settings_repository.dart';

class SetExchangeRateUsecase {
  final AdminSettingsRepository _repository;
  SetExchangeRateUsecase(this._repository);

  Future<Either<Failure, void>> call(double usdToIdr) {
    return _repository.setExchangeRate(usdToIdr);
  }
}
