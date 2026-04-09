// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_template_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormTemplateFieldDTO _$FormTemplateFieldDTOFromJson(
  Map<String, dynamic> json,
) => FormTemplateFieldDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  formTemplateId: json['formTemplateId'] as String? ?? '',
  description: json['description'] as String? ?? '',
  optional: json['optional'] as bool? ?? false,
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FormTemplateFieldDTOToJson(
  FormTemplateFieldDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'formTemplateId': instance.formTemplateId,
  'description': instance.description,
  'optional': instance.optional,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};

FormTemplateDTO _$FormTemplateDTOFromJson(Map<String, dynamic> json) =>
    FormTemplateDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String? ?? '',
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) => FormTemplateFieldDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FormTemplateDTOToJson(FormTemplateDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'description': instance.description,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
    };
