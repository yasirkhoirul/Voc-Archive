import 'package:dartz/dartz.dart';
import 'package:module_core/module_core.dart';
import '../entities/display_section.dart';
import '../repositories/home_repository.dart';

class GetDisplaySectionsUsecase {
  final HomeRepository _repository;

  GetDisplaySectionsUsecase(this._repository);

  Future<Either<Failure, List<DisplaySection>>> call() async {
    return await _repository.getDisplaySections();
  }
}
