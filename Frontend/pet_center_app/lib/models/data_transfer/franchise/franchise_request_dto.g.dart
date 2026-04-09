// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'franchise_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FranchiseRequestDTO _$FranchiseRequestDTOFromJson(Map<String, dynamic> json) =>
    FranchiseRequestDTO(
      creationFormId: json['creationFormId'] as String?,
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      franchiseName: json['franchiseName'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
    );

Map<String, dynamic> _$FranchiseRequestDTOToJson(
  FranchiseRequestDTO instance,
) => <String, dynamic>{
  'creationFormId': instance.creationFormId,
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'franchiseName': instance.franchiseName,
  'contact': instance.contact,
};
