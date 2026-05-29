// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breed_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedDTO _$BreedDTOFromJson(Map<String, dynamic> json) => BreedDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  kindId: json['kindId'] as String? ?? '',
  scale:
      $enumDecodeNullable(_$AnimalScaleEnumMap, json['scale']) ??
      AnimalScale.medium,
  investment: (json['investment'] as num?)?.toDouble() ?? 0.5,
  territory: (json['territory'] as num?)?.toDouble() ?? 0.5,
  pricing: (json['pricing'] as num?)?.toDouble() ?? 0.5,
  longevity: (json['longevity'] as num?)?.toDouble() ?? 0.5,
  cohabitation: (json['cohabitation'] as num?)?.toDouble() ?? 0.5,
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String? ?? '',
  albumId: json['albumId'] as String?,
  locked: json['locked'] as bool? ?? true,
  full: json['full'] as bool? ?? true,
  mediaCreationToken: json['mediaCreationToken'] as String?,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => ImageDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BreedDTOToJson(BreedDTO instance) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'kindId': instance.kindId,
  'scale': _$AnimalScaleEnumMap[instance.scale]!,
  'investment': instance.investment,
  'territory': instance.territory,
  'pricing': instance.pricing,
  'longevity': instance.longevity,
  'cohabitation': instance.cohabitation,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'albumId': instance.albumId,
  'media': instance.media.map((e) => e.toJson()).toList(),
  'locked': instance.locked,
  'full': instance.full,
  'mediaCreationToken': instance.mediaCreationToken,
};

const _$AnimalScaleEnumMap = {
  AnimalScale.small: 0,
  AnimalScale.medium: 1,
  AnimalScale.large: 2,
};
