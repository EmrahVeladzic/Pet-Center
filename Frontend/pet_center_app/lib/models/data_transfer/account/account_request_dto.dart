import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/enums.dart';
part 'account_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountRequestDTO {
  String? id;
  String currentVersion;
  String contact;
  String password;
  String newPassword;
  Access role;

  AccountRequestDTO({
    this.id,
    this.currentVersion = '',
    this.contact = '',
    this.password = '',
    this.newPassword = '',
    this.role = Access.user,
  });

  factory AccountRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AccountRequestDTOToJson(this);

  AccountRequestDTO copy() => AccountRequestDTO(
    id: id,
    currentVersion: currentVersion,
    contact: contact,
    password: password,
    role: role,
    newPassword: newPassword,
  );
}
