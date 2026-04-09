// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualRequestDTO _$IndividualRequestDTOFromJson(
  Map<String, dynamic> json,
) => IndividualRequestDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  name: json['name'] as String? ?? '',
  breedId: json['breedId'] as String? ?? '',
  sex: json['sex'] as bool? ?? false,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  shelterId: json['shelterId'] as String?,
);

Map<String, dynamic> _$IndividualRequestDTOToJson(
  IndividualRequestDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'name': instance.name,
  'breedId': instance.breedId,
  'sex': instance.sex,
  'birthDate': instance.birthDate.toIso8601String(),
  'shelterId': instance.shelterId,
};
