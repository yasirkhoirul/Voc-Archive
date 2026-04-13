import 'package:dartz/dartz.dart';
import 'package:module_core/module_core.dart';
import '../entities/display_section.dart';
import '../entities/slider.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<DisplaySection>>> getDisplaySections();
  Future<Either<Failure, List<SliderData>>> getSliders();
}
