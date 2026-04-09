import 'package:json_annotation/json_annotation.dart';
part 'franchise_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FranchiseRequestDTO {
  String? creationFormId;
  String? id;
  String currentVersion;
  String franchiseName;
  String contact;

  FranchiseRequestDTO({
    this.creationFormId,
    this.id,
    this.currentVersion = '',
    this.franchiseName = '',
    this.contact = '',
  });

  factory FranchiseRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$FranchiseRequestDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FranchiseRequestDTOToJson(this);
}
