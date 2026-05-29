import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'franchise_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FranchiseResponseDTO {
  String? id;
  String currentVersion;
  String franchiseName;
  String contact;
  List<NoteSubDTO>? notes;
  List<FacilityDTO> facilities;
  List<IndividualResponseDTO> shelteredAnimals;
  bool? owned;

  FranchiseResponseDTO({
    this.id,
    this.currentVersion = '',
    this.franchiseName = '',
    this.contact = '',
    this.notes,
    this.owned,
    this.facilities = const [],
    this.shelteredAnimals = const [],
  });

  factory FranchiseResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$FranchiseResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$FranchiseResponseDTOToJson(this);

  FranchiseResponseDTO copy() => FranchiseResponseDTO(
    id: id,
    currentVersion: currentVersion,
    franchiseName: franchiseName,
    contact: contact,
    notes: notes?.map((n) => n.copy()).toList(),
    owned: owned,
    facilities: facilities.map((f) => f.copy()).toList(),
    shelteredAnimals: shelteredAnimals.map((s) => s.copy()).toList(),
  );
}
