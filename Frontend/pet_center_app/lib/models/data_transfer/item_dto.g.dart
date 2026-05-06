// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemDTO _$ItemDTOFromJson(Map<String, dynamic> json) => ItemDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String? ?? '',
  categoryId: json['categoryId'] as String? ?? '',
  kindId: json['kindId'] as String? ?? '',
  scale: $enumDecodeNullable(_$AnimalScaleEnumMap, json['scale']),
  mass: (json['mass'] as num?)?.toInt(),
);

Map<String, dynamic> _$ItemDTOToJson(ItemDTO instance) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'categoryId': instance.categoryId,
  'kindId': instance.kindId,
  'scale': _$AnimalScaleEnumMap[instance.scale],
  'mass': instance.mass,
};

const _$AnimalScaleEnumMap = {
  AnimalScale.small: 0,
  AnimalScale.medium: 1,
  AnimalScale.large: 2,
};
