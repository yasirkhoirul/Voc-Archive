import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/create_slider_input.dart';
import '../entities/create_display_input.dart';
import '../entities/update_display_input.dart';

abstract class AdminHomeRepository {
  Future<Either<Failure, void>> createSlider(CreateSliderInput input);
  Future<Either<Failure, void>> deleteSlider(String uid);
  Future<Either<Failure, void>> createDisplay(CreateDisplayInput input);
  Future<Either<Failure, void>> updateDisplay(UpdateDisplayInput input);
  Future<Either<Failure, void>> deleteDisplay(String uid);
}
