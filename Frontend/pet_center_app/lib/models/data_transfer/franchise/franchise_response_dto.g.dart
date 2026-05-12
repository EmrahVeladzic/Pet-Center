// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'franchise_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FranchiseResponseDTO _$FranchiseResponseDTOFromJson(
  Map<String, dynamic> json,
) => FranchiseResponseDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  franchiseName: json['franchiseName'] as String? ?? '',
  contact: json['contact'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  owned: json['owned'] as bool?,
  facilities:
      (json['facilities'] as List<dynamic>?)
          ?.map((e) => FacilityDTO.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$FranchiseResponseDTOToJson(
  FranchiseResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'franchiseName': instance.franchiseName,
  'contact': instance.contact,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'facilities': instance.facilities.map((e) => e.toJson()).toList(),
  'owned': instance.owned,
};
