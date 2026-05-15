import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/enums.dart';
part 'item_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ItemDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String title;
  String categoryId;
  String kindId;
  AnimalScale? scale;
  int? mass;

  ItemDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.title = '',
    this.categoryId = '',
    this.kindId = '',
    this.scale,
    this.mass,
  });

  factory ItemDTO.fromJson(Map<String, dynamic> json) =>
      _$ItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDTOToJson(this);

  ItemDTO copy() => ItemDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    title: title,
    categoryId: categoryId,
    kindId: kindId,
    scale: scale,
    mass: mass,
  );
}
