import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'procedure_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ProcedureSpecificationSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String procedureID;
  String kindId;
  String? breedId;
  bool optional;
  bool? sexSpecific;
  int? approximateAge;
  int? interval;

  ProcedureSpecificationSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.procedureID = '',
    this.kindId = '',
    this.breedId,
    this.optional = true,
    this.sexSpecific,
    this.approximateAge,
    this.interval,
  });

  factory ProcedureSpecificationSubDTO.fromJson(Map<String, dynamic> json) =>
      _$ProcedureSpecificationSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProcedureSpecificationSubDTOToJson(this);

  ProcedureSpecificationSubDTO copy() => ProcedureSpecificationSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    procedureID: procedureID,
    kindId: kindId,
    breedId: breedId,
    optional: optional,
    sexSpecific: sexSpecific,
    approximateAge: approximateAge,
    interval: interval,
  );
}

@JsonSerializable(explicitToJson: true)
class ProcedureDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String description;
  List<ProcedureSpecificationSubDTO> specifications;

  ProcedureDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.description = '',
    List<ProcedureSpecificationSubDTO>? specifications,
  }) : specifications = specifications ?? [];

  factory ProcedureDTO.fromJson(Map<String, dynamic> json) =>
      _$ProcedureDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProcedureDTOToJson(this);

  ProcedureDTO copy() => ProcedureDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    description: description,
    specifications: specifications.map((s) => s.copy()).toList(),
  );
}
