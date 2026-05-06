import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
part 'franchise_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FranchiseResponseDTO {
  String? id;
  String currentVersion;
  String? franchiseName;
  String? contact;
  String albumId;
  List<ImageDTO?>? images;
  List<NoteSubDTO>? notes;
  bool? owned;

  FranchiseResponseDTO({
    this.id,
    this.currentVersion = '',
    this.franchiseName,
    this.contact,
    this.albumId = '',
    this.images,
    this.notes,
    this.owned,
  });

  factory FranchiseResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$FranchiseResponseDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FranchiseResponseDTOToJson(this);
}
