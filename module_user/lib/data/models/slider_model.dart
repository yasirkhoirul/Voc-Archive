import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/shared_data/models/timestamp_converter.dart';
import '../../domain/entities/slider.dart';

part 'slider_model.g.dart';

@JsonSerializable()
@TimestampConverter()
class SliderModel extends SliderData {
  const SliderModel({
    required super.uid,
    required super.judul,
    required super.deskripsi,
    required super.gambar,
    @JsonKey(name: 'gambar_path') required super.gambarPath,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) =>
      _$SliderModelFromJson(json);
  Map<String, dynamic> toJson() => _$SliderModelToJson(this);
}
