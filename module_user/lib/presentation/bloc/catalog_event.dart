part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class FetchCatalogProducts extends CatalogEvent {
  final String? query;
  final List<String>? types;
  final double? minPrice;
  final double? maxPrice;

  const FetchCatalogProducts({
    this.query,
    this.types,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [query, types, minPrice, maxPrice];
}
