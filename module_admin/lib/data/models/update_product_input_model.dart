import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/update_product_input.dart';

part 'update_product_input_model.g.dart';

@JsonSerializable()
class UpdateProductInputModel extends UpdateProductInput {
  const UpdateProductInputModel({
    required super.uid,
    @JsonKey(name: 'gambar_base64') super.gambarBase64,
    @JsonKey(name: 'keep_gambar_paths') super.keepGambarPaths,
    @JsonKey(name: 'nama_brand') super.namaBrand,
    super.harga,
    super.deskripsi,
    super.detail,
    super.sizes,
    super.diskon,
  });

  factory UpdateProductInputModel.fromJson(Map<String, dynamic> json) => _$UpdateProductInputModelFromJson(json);
  
  Map<String, dynamic> toJson() {
    final map = _$UpdateProductInputModelToJson(this);
    map.removeWhere((key, value) => value == null);
    // remove empty array to pass validation if there are no new images
    if (map['gambar_base64'] != null && (map['gambar_base64'] as List).isEmpty) {
      map.remove('gambar_base64');
    }
    return map;
  }

  factory UpdateProductInputModel.fromEntity(UpdateProductInput entity) {
    return UpdateProductInputModel(
      uid: entity.uid,
      gambarBase64: entity.gambarBase64,
      keepGambarPaths: entity.keepGambarPaths,
      namaBrand: entity.namaBrand,
      harga: entity.harga,
      deskripsi: entity.deskripsi,
      detail: entity.detail,
      sizes: entity.sizes,
      diskon: entity.diskon,
    );
  }
}
