import 'package:json_annotation/json_annotation.dart';
import '../../shared_domain/shared_entities/product.dart';
import 'timestamp_converter.dart';

part 'product_model.g.dart';

@JsonSerializable()
@TimestampConverter()
class ProductModel extends Product {
  const ProductModel({
    required super.uid,
    required super.gambar,
    @JsonKey(name: 'gambar_paths') required super.gambarPaths,
    @JsonKey(name: 'nama_brand') required super.namaBrand,
    required super.harga,
    required super.deskripsi,
    required super.detail,
    required super.sizes,
    @JsonKey(name: 'total_stok') required super.totalStok,
    required super.diskon,
    @JsonKey(name: 'harga_diskon') required super.hargaDiskon,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
