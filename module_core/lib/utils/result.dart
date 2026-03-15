class Result<T> {
  final T? data;
  final Object? error;

  const Result({this.data, this.error});

  factory Result.success(T data) => Result(data: data);
  factory Result.error(Object error) => Result(error: error);

  bool get isSuccess => data != null && error == null;
  bool get isError => error != null && data == null;
}