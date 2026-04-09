// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaticDataDTO _$StaticDataDTOFromJson(Map<String, dynamic> json) =>
    StaticDataDTO(
      kindVersion: json['kindVersion'] as String? ?? '',
      breedVersion: json['breedVersion'] as String? ?? '',
      categoryVersion: json['categoryVersion'] as String? ?? '',
      productVersion: json['productVersion'] as String? ?? '',
      usageVersion: json['usageVersion'] as String? ?? '',
      announcementVersion: json['announcementVersion'] as String? ?? '',
      formTemplateVersion: json['formTemplateVersion'] as String? ?? '',
      livingConditionVersion: json['livingConditionVersion'] as String? ?? '',
      procedureVersion: json['procedureVersion'] as String? ?? '',
      specificationVersion: json['specificationVersion'] as String? ?? '',
    );

Map<String, dynamic> _$StaticDataDTOToJson(StaticDataDTO instance) =>
    <String, dynamic>{
      'kindVersion': instance.kindVersion,
      'breedVersion': instance.breedVersion,
      'categoryVersion': instance.categoryVersion,
      'productVersion': instance.productVersion,
      'usageVersion': instance.usageVersion,
      'announcementVersion': instance.announcementVersion,
      'formTemplateVersion': instance.formTemplateVersion,
      'livingConditionVersion': instance.livingConditionVersion,
      'procedureVersion': instance.procedureVersion,
      'specificationVersion': instance.specificationVersion,
    };
