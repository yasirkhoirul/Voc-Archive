// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  uid: json['uid'] as String,
  gambar: (json['gambar'] as List<dynamic>).map((e) => e as String).toList(),
  namaBrand: json['nama_brand'] as String,
  harga: (json['harga'] as num).toDouble(),
  deskripsi: json['deskripsi'] as String,
  detail: json['detail'] as String,
  sizes: Map<String, int>.from(json['sizes'] as Map),
  totalStok: (json['total_stok'] as num).toInt(),
  diskon: (json['diskon'] as num).toDouble(),
  hargaDiskon: (json['harga_diskon'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'gambar': instance.gambar,
      'nama_brand': instance.namaBrand,
      'harga': instance.harga,
      'deskripsi': instance.deskripsi,
      'detail': instance.detail,
      'sizes': instance.sizes,
      'total_stok': instance.totalStok,
      'diskon': instance.diskon,
      'harga_diskon': instance.hargaDiskon,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
