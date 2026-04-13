part of 'brand_bloc.dart';

abstract class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object?> get props => [];
}

class LoadBrands extends BrandEvent {}

class CreateBrandSubmitted extends BrandEvent {
  final String nama;

  const CreateBrandSubmitted(this.nama);

  @override
  List<Object?> get props => [nama];
}

class UpdateBrandSubmitted extends BrandEvent {
  final String uid;
  final String nama;

  const UpdateBrandSubmitted(this.uid, this.nama);

  @override
  List<Object?> get props => [uid, nama];
}

class DeleteBrandSubmitted extends BrandEvent {
  final String uid;

  const DeleteBrandSubmitted(this.uid);

  @override
  List<Object?> get props => [uid];
}
