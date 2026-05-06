// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityDTO _$FacilityDTOFromJson(Map<String, dynamic> json) => FacilityDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  owningFranchise: json['owningFranchise'] as String? ?? '',
  street: json['street'] as String? ?? '',
  city: json['city'] as String? ?? '',
  contact: json['contact'] as String?,
);

Map<String, dynamic> _$FacilityDTOToJson(FacilityDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'owningFranchise': instance.owningFranchise,
      'street': instance.street,
      'city': instance.city,
      'contact': instance.contact,
    };
