import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import 'package:module_core/utils/runcatching.dart';
import '../../shared_domain/shared_repositories/shared_brand_repository.dart';
import '../datasources/shared_brand_datasource.dart';

class SharedBrandRepositoryImpl implements SharedBrandRepository {
  final SharedBrandDatasource _datasource;

  SharedBrandRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBrands() async {
    return await _datasource.getBrands().guard();
  }
}

