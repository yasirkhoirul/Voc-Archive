import 'package:json_annotation/json_annotation.dart';
import 'package:module_admin/domain/entities/create_slider_input.dart';

part 'create_slider_input_model.g.dart';

@JsonSerializable()
class CreateSliderInputModel extends CreateSliderInput {
  const CreateSliderInputModel({
    required super.judul,
    required super.deskripsi,
    @JsonKey(name: 'gambar_base64') required super.gambarBase64,
  });

  factory CreateSliderInputModel.fromJson(Map<String, dynamic> json) =>
      _$CreateSliderInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSliderInputModelToJson(this);

  factory CreateSliderInputModel.fromEntity(CreateSliderInput entity) {
    return CreateSliderInputModel(
      judul: entity.judul,
      deskripsi: entity.deskripsi,
      gambarBase64: entity.gambarBase64,
    );
  }
}
