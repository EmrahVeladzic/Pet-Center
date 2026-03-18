// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountResponseDTO _$AccountResponseDTOFromJson(Map<String, dynamic> json) =>
    AccountResponseDTO(
        id: json['id'] as String?,
        currentVersion: json['currentVersion'] as String? ?? '',
        accessLevel:
            $enumDecodeNullable(_$AccessEnumMap, json['accessLevel']) ??
            Access.user,
        contact: json['contact'] as String? ?? '',
        verified: json['verified'] as bool? ?? false,
      )
      ..notes = (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$AccountResponseDTOToJson(AccountResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'accessLevel': _$AccessEnumMap[instance.accessLevel]!,
      'contact': instance.contact,
      'verified': instance.verified,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
    };

const _$AccessEnumMap = {
  Access.owner: 255,
  Access.admin: 254,
  Access.business: 1,
  Access.user: 0,
};
