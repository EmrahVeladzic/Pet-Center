import 'package:json_annotation/json_annotation.dart';

part 'account_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountRequestDTO {
  String? id;
  String currentVersion;
  String contact;
  String password;
  bool business;

  AccountRequestDTO({
    this.id,
    this.currentVersion = '',
    this.contact = '',
    this.password = '',
    this.business = false,
  });

  factory AccountRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountRequestDTOFromJson(json);
  Map<String, dynamic> toJson() => _$AccountRequestDTOToJson(this);
}
