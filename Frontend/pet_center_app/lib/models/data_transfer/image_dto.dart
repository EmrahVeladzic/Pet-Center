import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';

part 'image_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ImageDTO {
  String? id;
  String currentVersion;
  String albumInsertId;
  int width;
  int height;
  String? data;
  List<NoteSubDTO>? notes;
  ImageDTO({
    this.id,
    this.currentVersion = '',
    this.albumInsertId = '',
    this.width = 0,
    this.height = 0,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) =>
      _$ImageDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDTOToJson(this);
}
