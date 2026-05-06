import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/enums.dart';

part 'account_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountResponseDTO {
  String? id;
  String currentVersion;
  Access accessLevel;
  String contact;
  bool verified;
  List<NoteSubDTO>? notes;

  AccountResponseDTO({
    this.id,
    this.currentVersion = '',
    this.accessLevel = Access.user,
    this.contact = '',
    this.verified = false,
  });

  factory AccountResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseDTOToJson(this);
}
