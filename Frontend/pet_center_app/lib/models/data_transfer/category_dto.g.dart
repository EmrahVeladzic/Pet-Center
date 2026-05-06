// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageSubDTO _$UsageSubDTOFromJson(Map<String, dynamic> json) => UsageSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  categoryId: json['categoryId'] as String? ?? '',
  kindId: json['kindId'] as String? ?? '',
  scaleSpecific: $enumDecodeNullable(
    _$AnimalScaleEnumMap,
    json['scaleSpecific'],
  ),
  averageDailyAmountGrams:
      (json['averageDailyAmountGrams'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UsageSubDTOToJson(UsageSubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'categoryId': instance.categoryId,
      'kindId': instance.kindId,
      'scaleSpecific': _$AnimalScaleEnumMap[instance.scaleSpecific],
      'averageDailyAmountGrams': instance.averageDailyAmountGrams,
    };

const _$AnimalScaleEnumMap = {
  AnimalScale.small: 0,
  AnimalScale.medium: 1,
  AnimalScale.large: 2,
};

CategoryDTO _$CategoryDTOFromJson(Map<String, dynamic> json) => CategoryDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String? ?? '',
  consumable: json['consumable'] as bool? ?? false,
  usageSpecifics: (json['usageSpecifics'] as List<dynamic>?)
      ?.map(
        (e) =>
            e == null ? null : UsageSubDTO.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$CategoryDTOToJson(
  CategoryDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'consumable': instance.consumable,
  'usageSpecifics': instance.usageSpecifics?.map((e) => e?.toJson()).toList(),
};
