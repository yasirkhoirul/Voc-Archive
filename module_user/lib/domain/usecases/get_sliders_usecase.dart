import 'package:dartz/dartz.dart';
import 'package:module_core/module_core.dart';
import '../entities/slider.dart';
import '../repositories/home_repository.dart';

class GetSlidersUsecase {
  final HomeRepository _repository;

  GetSlidersUsecase(this._repository);

  Future<Either<Failure, List<SliderData>>> call() async {
    return await _repository.getSliders();
  }
}
