import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'facility_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FacilityDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String owningFranchise;
  String street;
  String city;
  String? contact;

  FacilityDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.owningFranchise = '',
    this.street = '',
    this.city = '',
    this.contact,
  });

  factory FacilityDTO.fromJson(Map<String, dynamic> json) =>
      _$FacilityDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FacilityDTOToJson(this);
}
