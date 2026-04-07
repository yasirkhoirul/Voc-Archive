import 'package:json_annotation/json_annotation.dart';
import 'package:module_admin/domain/entities/create_display_input.dart';

part 'create_display_input_model.g.dart';

@JsonSerializable()
class CreateDisplayInputModel extends CreateDisplayInput {
  CreateDisplayInputModel({
    required super.judul,
    @JsonKey(name: 'product_ids') required super.productId,
  });

  factory CreateDisplayInputModel.fromJson(Map<String, dynamic> json) =>
      _$CreateDisplayInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDisplayInputModelToJson(this);

  factory CreateDisplayInputModel.fromEntity(CreateDisplayInput entity) {
    return CreateDisplayInputModel(
      judul: entity.judul,
      productId: entity.productId,
    );
  }
}
