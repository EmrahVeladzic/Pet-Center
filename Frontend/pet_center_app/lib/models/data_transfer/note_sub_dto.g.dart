// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_sub_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteSubDTO _$NoteSubDTOFromJson(Map<String, dynamic> json) => NoteSubDTO(
  title: json['title'] as String? ?? '',
  body: json['body'] as String? ?? '',
);

Map<String, dynamic> _$NoteSubDTOToJson(NoteSubDTO instance) =>
    <String, dynamic>{'title': instance.title, 'body': instance.body};
