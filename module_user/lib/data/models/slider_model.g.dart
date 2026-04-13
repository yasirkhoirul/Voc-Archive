// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SliderModel _$SliderModelFromJson(Map<String, dynamic> json) => SliderModel(
  uid: json['uid'] as String,
  judul: json['judul'] as String,
  deskripsi: json['deskripsi'] as String,
  gambar: json['gambar'] as String,
  gambarPath: json['gambar_path'] as String,
  createdAt: const TimestampConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$SliderModelToJson(SliderModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'judul': instance.judul,
      'deskripsi': instance.deskripsi,
      'gambar': instance.gambar,
      'gambar_path': instance.gambarPath,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
