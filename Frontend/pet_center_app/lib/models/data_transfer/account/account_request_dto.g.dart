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
      business: json['business'] as bool? ?? false,
    );

Map<String, dynamic> _$AccountRequestDTOToJson(AccountRequestDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'contact': instance.contact,
      'password': instance.password,
      'business': instance.business,
    };
