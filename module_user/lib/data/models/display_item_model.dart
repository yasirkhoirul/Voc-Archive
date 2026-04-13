import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/shared_data/models/timestamp_converter.dart';
import '../../domain/entities/display_item.dart';

part 'display_item_model.g.dart';

@JsonSerializable()
@TimestampConverter()
class DisplayItemModel extends DisplayItem {
  const DisplayItemModel({
    required super.uid,
    required super.judul,
    @JsonKey(name: 'product_ids') required super.productIds,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') required super.updatedAt,
  });

  factory DisplayItemModel.fromJson(Map<String, dynamic> json) =>
      _$DisplayItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$DisplayItemModelToJson(this);
}
