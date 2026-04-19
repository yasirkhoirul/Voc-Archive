import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';

abstract class CatalogSoldOutState extends Equatable {
  const CatalogSoldOutState();

  @override
  List<Object> get props => [];
}

class CatalogSoldOutInitial extends CatalogSoldOutState {}

class CatalogSoldOutLoading extends CatalogSoldOutState {}

class CatalogSoldOutLoaded extends CatalogSoldOutState {
  final List<Product> products;

  const CatalogSoldOutLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class CatalogSoldOutError extends CatalogSoldOutState {
  final String message;

  const CatalogSoldOutError(this.message);

  @override
  List<Object> get props => [message];
}
