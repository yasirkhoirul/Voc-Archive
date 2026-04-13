// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisplayItemModel _$DisplayItemModelFromJson(Map<String, dynamic> json) =>
    DisplayItemModel(
      uid: json['uid'] as String,
      judul: json['judul'] as String,
      productIds: (json['product_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: const TimestampConverter().fromJson(json['created_at']),
      updatedAt: const TimestampConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$DisplayItemModelToJson(DisplayItemModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'judul': instance.judul,
      'product_ids': instance.productIds,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
    };
