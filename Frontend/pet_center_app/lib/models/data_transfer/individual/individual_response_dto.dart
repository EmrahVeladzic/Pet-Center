import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'individual_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MedicalEntrySubDTO {
  String? id;
  List<NoteSubDTO>? notes;
  String currentVersion;
  DateTime datePerformed;
  String procedureId;
  String animalId;

  MedicalEntrySubDTO({
    this.id,
    this.notes,
    this.currentVersion = '',
    DateTime? datePerformed,
    this.procedureId = '',
    this.animalId = '',
  }) : datePerformed = datePerformed ?? DateTime.now().toUtc();

  factory MedicalEntrySubDTO.fromJson(Map<String, dynamic> json) =>
      _$MedicalEntrySubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalEntrySubDTOToJson(this);

  MedicalEntrySubDTO copy() => MedicalEntrySubDTO(
    id: id,
    notes: notes?.map((n) => n.copy()).toList(),
    currentVersion: currentVersion,
    datePerformed: datePerformed,
    procedureId: procedureId,
    animalId: animalId,
  );
}

@JsonSerializable(explicitToJson: true)
class IndividualResponseDTO {
  String? id;
  String currentVersion;
  String identity;
  String name;
  String breedId;
  bool sex;
  DateTime birthDate;
  List<NoteSubDTO>? notes;
  List<MedicalEntrySubDTO> medicalRecord;

  IndividualResponseDTO({
    this.id,
    this.currentVersion = '',
    this.identity = '',
    this.name = '',
    this.breedId = '',
    this.sex = false,
    DateTime? birthDate,
    this.notes,
    List<MedicalEntrySubDTO>? medicalRecord,
  }) : birthDate = birthDate ?? DateTime.now().toUtc(),
       medicalRecord = medicalRecord ?? [];

  factory IndividualResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$IndividualResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualResponseDTOToJson(this);

  IndividualResponseDTO copy() => IndividualResponseDTO(
    id: id,
    currentVersion: currentVersion,
    identity: identity,
    name: name,
    breedId: breedId,
    sex: sex,
    birthDate: birthDate,
    notes: notes?.map((n) => n.copy()).toList(),
    medicalRecord: medicalRecord.map((m) => m.copy()).toList(),
  );
}
