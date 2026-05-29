// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procedure_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcedureSpecificationSubDTO _$ProcedureSpecificationSubDTOFromJson(
  Map<String, dynamic> json,
) => ProcedureSpecificationSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  procedureID: json['procedureID'] as String? ?? '',
  kindId: json['kindId'] as String? ?? '',
  breedId: json['breedId'] as String?,
  optional: json['optional'] as bool? ?? true,
  sexSpecific: json['sexSpecific'] as bool?,
  approximateAge: (json['approximateAge'] as num?)?.toInt() ?? 31,
  interval: (json['interval'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$ProcedureSpecificationSubDTOToJson(
  ProcedureSpecificationSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'procedureID': instance.procedureID,
  'kindId': instance.kindId,
  'breedId': instance.breedId,
  'optional': instance.optional,
  'sexSpecific': instance.sexSpecific,
  'approximateAge': instance.approximateAge,
  'interval': instance.interval,
};

ProcedureDTO _$ProcedureDTOFromJson(Map<String, dynamic> json) => ProcedureDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['description'] as String? ?? '',
  specifications: (json['specifications'] as List<dynamic>?)
      ?.map(
        (e) => ProcedureSpecificationSubDTO.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ProcedureDTOToJson(ProcedureDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'description': instance.description,
      'specifications': instance.specifications.map((e) => e.toJson()).toList(),
    };
