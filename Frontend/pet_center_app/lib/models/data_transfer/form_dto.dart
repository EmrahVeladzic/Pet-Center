import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
part 'form_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FormEntrySubDTO {
  String? id;
  String currentVersion;
  String formId;
  String formTemplateFieldId;
  String serialized;
  List<NoteSubDTO>? notes;

  FormEntrySubDTO({
    this.id,
    this.currentVersion = '',
    this.formId = '',
    this.formTemplateFieldId = '',
    this.serialized = '',
    this.notes,
  });

  factory FormEntrySubDTO.fromJson(Map<String, dynamic> json) =>
      _$FormEntrySubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FormEntrySubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FormDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String franchiseName;
  String defaultContact;
  List<FormEntrySubDTO> entries;
  String userId;
  String formTemplateId;
  String albumId;
  List<ImageDTO> media;
  bool locked;
  bool full;
  String? mediaCreationToken;

  FormDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.franchiseName = '',
    this.defaultContact = '',
    List<FormEntrySubDTO>? entries,
    this.userId = '',
    this.formTemplateId = '',
    this.albumId = '',
    this.mediaCreationToken,
    this.locked = true,
    this.full = true,
    List<ImageDTO>? media,
  }) : entries = entries ?? [],
       media = media ?? [];

  factory FormDTO.fromJson(Map<String, dynamic> json) =>
      _$FormDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FormDTOToJson(this);
}
