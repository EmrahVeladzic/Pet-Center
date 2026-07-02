// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountRequestDTO _$AccountRequestDTOFromJson(Map<String, dynamic> json) =>
    AccountRequestDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: $enumDecodeNullable(_$AccessEnumMap, json['role']) ?? Access.user,
    );

Map<String, dynamic> _$AccountRequestDTOToJson(AccountRequestDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'contact': instance.contact,
      'password': instance.password,
      'role': _$AccessEnumMap[instance.role]!,
    };

const _$AccessEnumMap = {
  Access.owner: 255,
  Access.admin: 254,
  Access.business: 1,
  Access.user: 0,
};
