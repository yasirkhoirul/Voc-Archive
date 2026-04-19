import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';

abstract class AdminSettingsRepository {
  Future<Either<Failure, void>> setExchangeRate(double usdToIdr);
  Future<Either<Failure, void>> addShippingRate(String namaArea, double harga);
  Future<Either<Failure, void>> updateShippingRate(
    String namaArea,
    double harga,
  );
  Future<Either<Failure, void>> deleteShippingRate(String namaArea);
}
