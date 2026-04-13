import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';

abstract class CatalogDiscountState extends Equatable {
  const CatalogDiscountState();

  @override
  List<Object> get props => [];
}

class CatalogDiscountInitial extends CatalogDiscountState {}

class CatalogDiscountLoading extends CatalogDiscountState {}

class CatalogDiscountLoaded extends CatalogDiscountState {
  final List<Product> products;

  const CatalogDiscountLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class CatalogDiscountError extends CatalogDiscountState {
  final String message;

  const CatalogDiscountError(this.message);

  @override
  List<Object> get props => [message];
}
