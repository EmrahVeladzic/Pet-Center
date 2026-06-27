import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/models/enums.dart';
part 'form_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FormEntrySubDTO {
  String? id;
  String currentVersion;
  String? formId;
  String formTemplateFieldId;
  String serialized;
  List<NoteSubDTO>? notes;

  FormEntrySubDTO({
    this.id,
    this.currentVersion = '',
    this.formId,
    this.formTemplateFieldId = '',
    this.serialized = '',
    this.notes,
  });

  FormEntrySubDTO copy() => FormEntrySubDTO(
    id: id,
    currentVersion: currentVersion,
    formId: formId,
    formTemplateFieldId: formTemplateFieldId,
    serialized: serialized,
    notes: notes?.map((n) => n.copy()).toList(),
  );

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
  String? albumId;
  List<ImageDTO> media;
  bool locked;
  bool full;
  String? mediaCreationToken;
  String? evalContact;
  DateTime? evalDate;
  String? evalReason;
  EvaluationStatus status;

  FormDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.franchiseName = '',
    this.defaultContact = '',
    List<FormEntrySubDTO>? entries,
    this.userId = '',
    this.formTemplateId = '',
    this.albumId,
    this.mediaCreationToken,
    this.locked = true,
    this.full = true,
    List<ImageDTO>? media,
    this.evalContact,
    this.evalDate,
    this.evalReason,
    this.status = EvaluationStatus.pending,
  }) : entries = entries ?? [],
       media = media ?? [];

  FormDTO copy() => FormDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    franchiseName: franchiseName,
    defaultContact: defaultContact,
    entries: entries.map((e) => e.copy()).toList(),
    userId: userId,
    formTemplateId: formTemplateId,
    albumId: albumId,
    mediaCreationToken: mediaCreationToken,
    locked: locked,
    full: full,
    media: media.map((m) => m.copy()).toList(),
    evalContact: evalContact,
    evalDate: evalDate,
    evalReason: evalReason,
    status: status,
  );

  factory FormDTO.fromJson(Map<String, dynamic> json) =>
      _$FormDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FormDTOToJson(this);
}
