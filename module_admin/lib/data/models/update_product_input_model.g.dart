// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProductInputModel _$UpdateProductInputModelFromJson(
  Map<String, dynamic> json,
) => UpdateProductInputModel(
  uid: json['uid'] as String,
  gambarBase64: (json['gambar_base64'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  keepGambarPaths: (json['keep_gambar_paths'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  namaBrand: json['nama_brand'] as String?,
  harga: (json['harga'] as num?)?.toDouble(),
  deskripsi: json['deskripsi'] as String?,
  detail: json['detail'] as String?,
  sizes: (json['sizes'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  diskon: (json['diskon'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UpdateProductInputModelToJson(
  UpdateProductInputModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'gambar_base64': instance.gambarBase64,
  'keep_gambar_paths': instance.keepGambarPaths,
  'nama_brand': instance.namaBrand,
  'harga': instance.harga,
  'deskripsi': instance.deskripsi,
  'detail': instance.detail,
  'sizes': instance.sizes,
  'diskon': instance.diskon,
};
