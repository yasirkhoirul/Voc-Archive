import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_settings_repository.dart';

class UpdateShippingRateUsecase {
  final AdminSettingsRepository _repository;
  UpdateShippingRateUsecase(this._repository);

  Future<Either<Failure, void>> call(String namaArea, double harga) {
    return _repository.updateShippingRate(namaArea, harga);
  }
}
