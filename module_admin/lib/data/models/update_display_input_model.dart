import 'package:json_annotation/json_annotation.dart';
import 'package:module_admin/domain/entities/update_display_input.dart';

part 'update_display_input_model.g.dart';

@JsonSerializable()
class UpdateDisplayInputModel extends UpdateDisplayInput {
  UpdateDisplayInputModel({
    required super.uid,
    required super.judul,
    @JsonKey(name: 'product_ids') required super.productId,
  });

  factory UpdateDisplayInputModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateDisplayInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDisplayInputModelToJson(this);

  factory UpdateDisplayInputModel.fromEntity(UpdateDisplayInput entity) {
    return UpdateDisplayInputModel(
      uid: entity.uid,
      judul: entity.judul,
      productId: entity.productId,
    );
  }
}
