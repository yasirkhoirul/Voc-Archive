part of 'catalog_bloc.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

final class CatalogInitial extends CatalogState {}

final class CatalogLoading extends CatalogState {}

final class CatalogLoaded extends CatalogState {
  final List<Product> products;

  const CatalogLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

final class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
