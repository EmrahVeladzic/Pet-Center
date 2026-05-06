import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'form_template_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FormTemplateFieldDTO {
  String? id;
  String currentVersion;
  String formTemplateId;
  String description;
  bool optional;
  List<NoteSubDTO>? notes;

  FormTemplateFieldDTO({
    this.id,
    this.currentVersion = '',
    this.formTemplateId = '',
    this.description = '',
    this.optional = false,
    this.notes,
  });

  factory FormTemplateFieldDTO.fromJson(Map<String, dynamic> json) =>
      _$FormTemplateFieldDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FormTemplateFieldDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FormTemplateDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String description;
  List<FormTemplateFieldDTO> fields;

  FormTemplateDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.description = '',
    List<FormTemplateFieldDTO>? fields,
  }) : fields = fields ?? [];

  factory FormTemplateDTO.fromJson(Map<String, dynamic> json) =>
      _$FormTemplateDTOFromJson(json);
  Map<String, dynamic> toJson() => _$FormTemplateDTOToJson(this);
}
