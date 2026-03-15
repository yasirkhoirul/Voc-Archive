// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProductInputModel _$CreateProductInputModelFromJson(
  Map<String, dynamic> json,
) => CreateProductInputModel(
  gambar: (json['gambar'] as List<dynamic>).map((e) => e as String).toList(),
  namaBrand: json['nama_brand'] as String,
  harga: (json['harga'] as num).toDouble(),
  deskripsi: json['deskripsi'] as String,
  detail: json['detail'] as String,
  sizes: Map<String, int>.from(json['sizes'] as Map),
  diskon: (json['diskon'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CreateProductInputModelToJson(
  CreateProductInputModel instance,
) => <String, dynamic>{
  'gambar': instance.gambar,
  'nama_brand': instance.namaBrand,
  'harga': instance.harga,
  'deskripsi': instance.deskripsi,
  'detail': instance.detail,
  'sizes': instance.sizes,
  'diskon': instance.diskon,
};
