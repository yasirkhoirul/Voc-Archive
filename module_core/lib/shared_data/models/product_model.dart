import 'package:json_annotation/json_annotation.dart';
import '../../shared_domain/shared_entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.uid,
    required super.gambar,
    @JsonKey(name: 'nama_brand') required super.namaBrand,
    required super.harga,
    required super.deskripsi,
    required super.detail,
    required super.sizes,
    @JsonKey(name: 'total_stok') required super.totalStok,
    required super.diskon,
    @JsonKey(name: 'harga_diskon') required super.hargaDiskon,
    @JsonKey(name: 'created_at', fromJson: _fromJson, toJson: _toJson) required super.createdAt,
    @JsonKey(name: 'updated_at', fromJson: _fromJson, toJson: _toJson) required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  static DateTime _fromJson(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    // Handle specific string format or firestore timestamp toDate() dynamically
    try {
      if (timestamp != null && timestamp.toString().contains('seconds=')) {
         return DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
      }
    } catch (_) {}
    return DateTime.now(); // fallback
  }
  static int _toJson(DateTime time) => time.millisecondsSinceEpoch;
}
