// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageDTO _$ImageDTOFromJson(Map<String, dynamic> json) =>
    ImageDTO(
        id: json['id'] as String?,
        currentVersion: json['currentVersion'] as String? ?? '',
        albumInsertId: json['albumInsertId'] as String? ?? '',
        width: (json['width'] as num?)?.toInt() ?? 0,
        height: (json['height'] as num?)?.toInt() ?? 0,
      )
      ..data = json['data'] as String?
      ..notes = (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ImageDTOToJson(ImageDTO instance) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'albumInsertId': instance.albumInsertId,
  'width': instance.width,
  'height': instance.height,
  'data': instance.data,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};
