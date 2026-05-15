import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
part 'kind_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class KindDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String title;
  List<BreedDTO> breeds;

  KindDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.title = '',
    List<BreedDTO>? breeds,
  }) : breeds = breeds ?? [];

  factory KindDTO.fromJson(Map<String, dynamic> json) =>
      _$KindDTOFromJson(json);

  Map<String, dynamic> toJson() => _$KindDTOToJson(this);

  KindDTO copy() => KindDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    title: title,
    breeds: breeds.map((b) => b.copy()).toList(),
  );
}
