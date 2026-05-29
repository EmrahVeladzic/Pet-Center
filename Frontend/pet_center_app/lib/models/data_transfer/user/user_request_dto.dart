import 'package:json_annotation/json_annotation.dart';
part 'user_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRequestDTO {
  String? id;
  String currentVersion;
  String userName;

  UserRequestDTO({this.id, this.currentVersion = '', this.userName = ''});

  factory UserRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$UserRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserRequestDTOToJson(this);

  UserRequestDTO copy() => UserRequestDTO(
    id: id,
    currentVersion: currentVersion,
    userName: userName,
  );
}
