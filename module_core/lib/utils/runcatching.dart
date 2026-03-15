import 'package:module_core/utils/result.dart';

extension FutureExt<T> on Future<T> {
  Future<Result<T>> guard() async {
    try {
      final result = await this;
      return Result.success(result);
    } catch (e) {
      return Result.error(e);
    }
  }
}