import 'package:cloud_functions/cloud_functions.dart';
import 'package:module_core/utils/runcatching.dart';
import 'package:module_admin/data/models/create_display_input_model.dart';
import 'package:module_admin/data/models/create_slider_input_model.dart';
import 'package:module_admin/data/models/update_display_input_model.dart';

abstract class AdminHomeDatasource {
  Future<void> createSlider(CreateSliderInputModel input);
  Future<void> deleteSlider(String uid);
  Future<void> createDisplay(CreateDisplayInputModel input);
  Future<void> updateDisplay(UpdateDisplayInputModel input);
  Future<void> deleteDisplay(String uid);
}

class AdminHomeDataSourceImpl implements AdminHomeDatasource {
  final FirebaseFunctions _functions;

  AdminHomeDataSourceImpl(this._functions);

  @override
  Future<void> createDisplay(CreateDisplayInputModel input) async {
    return await (() async {
      final callable = _functions.httpsCallable('createDisplay');
      final response = await callable.call(input.toJson());
      return response.data;
    })().guardDatasource();
  }

  @override
  Future<void> createSlider(CreateSliderInputModel input) async {
    return await (() async {
      final callable = _functions.httpsCallable('createSlider');
      final response = await callable.call(input.toJson());
      return response.data;
    })().guardDatasource();
  }

  @override
  Future<void> deleteDisplay(String uid) async {
    return await (() async {
      await _functions.httpsCallable('deleteDisplay').call({'uid': uid});
    })().guardDatasource();
  }

  @override
  Future<void> deleteSlider(String uid) async {
    return await (() async {
      await _functions.httpsCallable('deleteSlider').call({'uid': uid});
    })().guardDatasource();
  }

  @override
  Future<void> updateDisplay(UpdateDisplayInputModel input) async {
    return await (() async {
      final callable = _functions.httpsCallable('updateDisplay');
      final response = await callable.call(input.toJson());
      return response.data;
    })().guardDatasource();
  }
}