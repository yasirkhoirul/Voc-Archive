import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/create_product_input.dart';

part 'create_product_input_model.g.dart';

@JsonSerializable()
class CreateProductInputModel extends CreateProductInput {
  const CreateProductInputModel({
    @JsonKey(name: 'gambar_base64') required super.gambarBase64,
    @JsonKey(name: 'nama_brand') required super.namaBrand,
    required super.harga,
    required super.deskripsi,
    required super.detail,
    required super.sizes,
    super.diskon,
  });

  factory CreateProductInputModel.fromJson(Map<String, dynamic> json) => _$CreateProductInputModelFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProductInputModelToJson(this);

  factory CreateProductInputModel.fromEntity(CreateProductInput entity) {
    return CreateProductInputModel(
      gambarBase64: entity.gambarBase64,
      namaBrand: entity.namaBrand,
      harga: entity.harga,
      deskripsi: entity.deskripsi,
      detail: entity.detail,
      sizes: entity.sizes,
      diskon: entity.diskon,
    );
  }
}
