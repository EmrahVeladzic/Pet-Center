// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRequestDTO _$UserRequestDTOFromJson(Map<String, dynamic> json) =>
    UserRequestDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
    );

Map<String, dynamic> _$UserRequestDTOToJson(UserRequestDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'userName': instance.userName,
    };
