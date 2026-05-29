import 'package:json_annotation/json_annotation.dart';
part 'static_data_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StaticDataDTO {
  String kindVersion;
  String breedVersion;
  String categoryVersion;
  String productVersion;
  String usageVersion;
  String announcementVersion;
  String reportVersion;
  String formTemplateVersion;
  String livingConditionVersion;
  String procedureVersion;
  String specificationVersion;

  StaticDataDTO({
    this.kindVersion = '',
    this.breedVersion = '',
    this.categoryVersion = '',
    this.productVersion = '',
    this.usageVersion = '',
    this.announcementVersion = '',
    this.reportVersion = '',
    this.formTemplateVersion = '',
    this.livingConditionVersion = '',
    this.procedureVersion = '',
    this.specificationVersion = '',
  });

  factory StaticDataDTO.fromJson(Map<String, dynamic> json) =>
      _$StaticDataDTOFromJson(json);

  Map<String, dynamic> toJson() => _$StaticDataDTOToJson(this);

  StaticDataDTO copy() => StaticDataDTO(
    kindVersion: kindVersion,
    breedVersion: breedVersion,
    categoryVersion: categoryVersion,
    productVersion: productVersion,
    usageVersion: usageVersion,
    announcementVersion: announcementVersion,
    reportVersion: reportVersion,
    formTemplateVersion: formTemplateVersion,
    livingConditionVersion: livingConditionVersion,
    procedureVersion: procedureVersion,
    specificationVersion: specificationVersion,
  );
}
