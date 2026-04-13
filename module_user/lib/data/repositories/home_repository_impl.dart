import 'package:dartz/dartz.dart';
import 'package:module_core/module_core.dart';
import '../../domain/entities/display_section.dart';
import '../../domain/entities/slider.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource _datasource;

  HomeRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<DisplaySection>>> getDisplaySections() async {
    return await _datasource.getDisplaySections().guard();
  }

  @override
  Future<Either<Failure, List<SliderData>>> getSliders() async {
    return await _datasource.getSliders().guard();
  }
}
