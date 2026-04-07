// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_display_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDisplayInputModel _$CreateDisplayInputModelFromJson(
  Map<String, dynamic> json,
) => CreateDisplayInputModel(
  judul: json['judul'] as String,
  productId: (json['product_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateDisplayInputModelToJson(
  CreateDisplayInputModel instance,
) => <String, dynamic>{
  'judul': instance.judul,
  'product_ids': instance.productId,
};
