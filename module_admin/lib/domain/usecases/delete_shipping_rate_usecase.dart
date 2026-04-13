import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_settings_repository.dart';

class DeleteShippingRateUsecase {
  final AdminSettingsRepository _repository;
  DeleteShippingRateUsecase(this._repository);

  Future<Either<Failure, void>> call(String namaArea) {
    return _repository.deleteShippingRate(namaArea);
  }
}
