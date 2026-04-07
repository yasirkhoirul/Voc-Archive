// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_display_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDisplayInputModel _$UpdateDisplayInputModelFromJson(
  Map<String, dynamic> json,
) => UpdateDisplayInputModel(
  uid: json['uid'] as String,
  judul: json['judul'] as String?,
  productId: (json['product_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UpdateDisplayInputModelToJson(
  UpdateDisplayInputModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'judul': instance.judul,
  'product_ids': instance.productId,
};
