import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import 'package:module_core/utils/runcatching.dart';

import '../../domain/repositories/admin_home_repository.dart';
import '../../domain/entities/create_slider_input.dart';
import '../../domain/entities/create_display_input.dart';
import '../../domain/entities/update_display_input.dart';

import '../datasources/admin_home_datasource.dart';
import '../models/create_slider_input_model.dart';
import '../models/create_display_input_model.dart';
import '../models/update_display_input_model.dart';

class AdminHomeRepositoryImpl implements AdminHomeRepository {
  final AdminHomeDatasource _datasource;

  AdminHomeRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> createSlider(CreateSliderInput input) async {
    return await (() async {
      final inputModel = CreateSliderInputModel.fromEntity(input);
      await _datasource.createSlider(inputModel);
    })().guard();
  }

  @override
  Future<Either<Failure, void>> deleteSlider(String uid) async {
    return await (() async {
      await _datasource.deleteSlider(uid);
    })().guard();
  }

  @override
  Future<Either<Failure, void>> createDisplay(CreateDisplayInput input) async {
    return await (() async {
      final inputModel = CreateDisplayInputModel.fromEntity(input);
      await _datasource.createDisplay(inputModel);
    })().guard();
  }

  @override
  Future<Either<Failure, void>> updateDisplay(UpdateDisplayInput input) async {
    return await (() async {
      final inputModel = UpdateDisplayInputModel.fromEntity(input);
      await _datasource.updateDisplay(inputModel);
    })().guard();
  }

  @override
  Future<Either<Failure, void>> deleteDisplay(String uid) async {
    return await (() async {
      await _datasource.deleteDisplay(uid);
    })().guard();
  }
}
