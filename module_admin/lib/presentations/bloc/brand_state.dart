part of 'brand_bloc.dart';

enum BrandStatus {
  initial,
  loading,
  loaded,
  mutating,
  mutationSuccess,
  error,
}

class BrandState extends Equatable {
  final BrandStatus status;
  final List<Map<String, dynamic>> brands;
  final String? errorMessage;
  final String? successMessage;

  const BrandState({
    this.status = BrandStatus.initial,
    this.brands = const [],
    this.errorMessage,
    this.successMessage,
  });

  BrandState copyWith({
    BrandStatus? status,
    List<Map<String, dynamic>>? brands,
    String? errorMessage,
    String? successMessage,
  }) {
    return BrandState(
      status: status ?? this.status,
      brands: brands ?? this.brands,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, brands, errorMessage, successMessage];
}
