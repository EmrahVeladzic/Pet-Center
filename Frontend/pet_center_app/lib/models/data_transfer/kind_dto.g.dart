// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kind_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KindDTO _$KindDTOFromJson(Map<String, dynamic> json) => KindDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String? ?? '',
  breeds: (json['breeds'] as List<dynamic>?)
      ?.map((e) => BreedDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$KindDTOToJson(KindDTO instance) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'breeds': instance.breeds.map((e) => e.toJson()).toList(),
};
