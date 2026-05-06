import 'package:json_annotation/json_annotation.dart';

part 'note_sub_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class NoteSubDTO {
  String title;
  String body;

  NoteSubDTO({this.title = '', this.body = ''});

  factory NoteSubDTO.fromJson(Map<String, dynamic> json) =>
      _$NoteSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$NoteSubDTOToJson(this);
}
