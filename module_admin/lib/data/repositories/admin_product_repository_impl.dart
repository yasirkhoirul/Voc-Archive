import 'package:dartz/dartz.dart';
import '../../domain/entities/create_product_input.dart';
import '../models/create_product_input_model.dart';
import 'package:module_core/utils/failure.dart';
import 'package:module_core/utils/runcatching.dart';

import '../../domain/repositories/admin_product_repository.dart';
import '../datasources/admin_product_datasource.dart';

class AdminProductRepositoryImpl implements AdminProductRepository {
  final AdminProductDatasource _datasource;

  AdminProductRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> createProduct(CreateProductInput input) async {
    return await (() async {
      final inputModel = CreateProductInputModel.fromEntity(input);
      await _datasource.createProduct(inputModel);
    })().guard();
  }
}
