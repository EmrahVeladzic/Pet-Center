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
  franchiseName: json['franchiseName'] as String?,
  contact: json['contact'] as String?,
  albumId: json['albumId'] as String? ?? '',
  images: (json['images'] as List<dynamic>?)
      ?.map(
        (e) => e == null ? null : ImageDTO.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  owned: json['owned'] as bool?,
);

Map<String, dynamic> _$FranchiseResponseDTOToJson(
  FranchiseResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'franchiseName': instance.franchiseName,
  'contact': instance.contact,
  'albumId': instance.albumId,
  'images': instance.images?.map((e) => e?.toJson()).toList(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'owned': instance.owned,
};
