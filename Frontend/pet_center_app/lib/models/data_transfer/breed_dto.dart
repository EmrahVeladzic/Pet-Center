import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/models/enums.dart';
part 'breed_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class BreedDTO {
  String? id;
  String currentVersion;
  String kindId;
  AnimalScale scale;
  double investment;
  double territory;
  double pricing;
  double longevity;
  double cohabitation;
  List<NoteSubDTO>? notes;
  String title;
  String albumId;
  List<ImageDTO> media;
  bool locked;
  bool full;
  String? mediaCreationToken;

  BreedDTO({
    this.id,
    this.currentVersion = '',
    this.kindId = '',
    this.scale = AnimalScale.medium,
    this.investment = 0.0,
    this.territory = 0.0,
    this.pricing = 0.0,
    this.longevity = 0.0,
    this.cohabitation = 0.0,
    this.notes,
    this.title = '',
    this.albumId = '',
    this.locked = true,
    this.full = true,
    this.mediaCreationToken,
    List<ImageDTO>? media,
  }) : media = media ?? [];

  BreedDTO copy() => BreedDTO(
    id: id,
    currentVersion: currentVersion,
    kindId: kindId,
    scale: scale,
    investment: investment,
    territory: territory,
    pricing: pricing,
    longevity: longevity,
    cohabitation: cohabitation,
    notes: notes?.map((n) => n.copy()).toList(),
    title: title,
    albumId: albumId,
    locked: locked,
    full: full,
    mediaCreationToken: mediaCreationToken,
    media: media.map((m) => m.copy()).toList(),
  );

  factory BreedDTO.fromJson(Map<String, dynamic> json) =>
      _$BreedDTOFromJson(json);
  Map<String, dynamic> toJson() => _$BreedDTOToJson(this);
}
