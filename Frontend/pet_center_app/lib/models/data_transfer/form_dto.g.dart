// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormEntrySubDTO _$FormEntrySubDTOFromJson(Map<String, dynamic> json) =>
    FormEntrySubDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      formId: json['formId'] as String?,
      formTemplateFieldId: json['formTemplateFieldId'] as String? ?? '',
      serialized: json['serialized'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FormEntrySubDTOToJson(FormEntrySubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'formId': instance.formId,
      'formTemplateFieldId': instance.formTemplateFieldId,
      'serialized': instance.serialized,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
    };

FormDTO _$FormDTOFromJson(Map<String, dynamic> json) => FormDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  franchiseName: json['franchiseName'] as String? ?? '',
  defaultContact: json['defaultContact'] as String? ?? '',
  entries: (json['entries'] as List<dynamic>?)
      ?.map((e) => FormEntrySubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  userId: json['userId'] as String? ?? '',
  formTemplateId: json['formTemplateId'] as String? ?? '',
  albumId: json['albumId'] as String?,
  mediaCreationToken: json['mediaCreationToken'] as String?,
  locked: json['locked'] as bool? ?? true,
  full: json['full'] as bool? ?? true,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => ImageDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FormDTOToJson(FormDTO instance) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'franchiseName': instance.franchiseName,
  'defaultContact': instance.defaultContact,
  'entries': instance.entries.map((e) => e.toJson()).toList(),
  'userId': instance.userId,
  'formTemplateId': instance.formTemplateId,
  'albumId': instance.albumId,
  'media': instance.media.map((e) => e.toJson()).toList(),
  'locked': instance.locked,
  'full': instance.full,
  'mediaCreationToken': instance.mediaCreationToken,
};
