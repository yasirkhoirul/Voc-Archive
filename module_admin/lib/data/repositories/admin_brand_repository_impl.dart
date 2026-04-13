import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../datasources/admin_brand_datasource.dart';
import '../../domain/repositories/admin_brand_repository.dart';
import 'package:module_core/utils/runcatching.dart';

class AdminBrandRepositoryImpl implements AdminBrandRepository {
  final AdminBrandDatasource _datasource;

  AdminBrandRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> createBrand(String nama) async {
    return await _datasource.createBrand(nama).guard();
  }

  @override
  Future<Either<Failure, void>> updateBrand(String uid, String nama) async {
    return await _datasource.updateBrand(uid, nama).guard();
  }

  @override
  Future<Either<Failure, void>> deleteBrand(String uid) async {
    return await _datasource.deleteBrand(uid).guard();
  }
}

