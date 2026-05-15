import 'package:json_annotation/json_annotation.dart';
part 'individual_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class IndividualRequestDTO {
  String? id;
  String currentVersion;
  String name;
  String breedId;
  bool sex;
  DateTime birthDate;
  String? shelterId;

  IndividualRequestDTO({
    this.id,
    this.currentVersion = '',
    this.name = '',
    this.breedId = '',
    this.sex = false,
    DateTime? birthDate,
    this.shelterId,
  }) : birthDate = birthDate ?? DateTime.now().toUtc();

  factory IndividualRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$IndividualRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualRequestDTOToJson(this);

  IndividualRequestDTO copy() => IndividualRequestDTO(
    id: id,
    currentVersion: currentVersion,
    name: name,
    breedId: breedId,
    sex: sex,
    birthDate: birthDate,
    shelterId: shelterId,
  );
}
