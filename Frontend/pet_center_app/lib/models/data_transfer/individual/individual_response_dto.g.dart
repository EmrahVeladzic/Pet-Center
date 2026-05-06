// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalEntrySubDTO _$MedicalEntrySubDTOFromJson(Map<String, dynamic> json) =>
    MedicalEntrySubDTO(
      id: json['id'] as String?,
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentVersion: json['currentVersion'] as String? ?? '',
      datePerformed: json['datePerformed'] == null
          ? null
          : DateTime.parse(json['datePerformed'] as String),
      procedureId: json['procedureId'] as String? ?? '',
      animalId: json['animalId'] as String? ?? '',
    );

Map<String, dynamic> _$MedicalEntrySubDTOToJson(MedicalEntrySubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'currentVersion': instance.currentVersion,
      'datePerformed': instance.datePerformed.toIso8601String(),
      'procedureId': instance.procedureId,
      'animalId': instance.animalId,
    };

IndividualResponseDTO _$IndividualResponseDTOFromJson(
  Map<String, dynamic> json,
) => IndividualResponseDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  identity: json['identity'] as String? ?? '',
  name: json['name'] as String? ?? '',
  breedId: json['breedId'] as String? ?? '',
  sex: json['sex'] as bool? ?? false,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  medicalRecord: (json['medicalRecord'] as List<dynamic>?)
      ?.map((e) => MedicalEntrySubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$IndividualResponseDTOToJson(
  IndividualResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'identity': instance.identity,
  'name': instance.name,
  'breedId': instance.breedId,
  'sex': instance.sex,
  'birthDate': instance.birthDate.toIso8601String(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'medicalRecord': instance.medicalRecord.map((e) => e.toJson()).toList(),
};
