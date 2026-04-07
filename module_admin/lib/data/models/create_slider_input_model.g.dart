// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_slider_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSliderInputModel _$CreateSliderInputModelFromJson(
  Map<String, dynamic> json,
) => CreateSliderInputModel(
  judul: json['judul'] as String,
  deskripsi: json['deskripsi'] as String,
  gambarBase64: json['gambar_base64'] as String,
);

Map<String, dynamic> _$CreateSliderInputModelToJson(
  CreateSliderInputModel instance,
) => <String, dynamic>{
  'judul': instance.judul,
  'deskripsi': instance.deskripsi,
  'gambar_base64': instance.gambarBase64,
};
