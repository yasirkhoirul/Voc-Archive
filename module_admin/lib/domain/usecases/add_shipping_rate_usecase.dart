import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_settings_repository.dart';

class AddShippingRateUsecase {
  final AdminSettingsRepository _repository;
  AddShippingRateUsecase(this._repository);

  Future<Either<Failure, void>> call(String namaArea, double harga) {
    return _repository.addShippingRate(namaArea, harga);
  }
}
