import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/enums.dart';
part 'category_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UsageSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String categoryId;
  String kindId;
  AnimalScale? scaleSpecific;
  int averageDailyAmountGrams;

  UsageSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.categoryId = '',
    this.kindId = '',
    this.scaleSpecific,
    this.averageDailyAmountGrams = 0,
  });

  factory UsageSubDTO.fromJson(Map<String, dynamic> json) =>
      _$UsageSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$UsageSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CategoryDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String title;
  bool consumable;
  List<UsageSubDTO?>? usageSpecifics;

  CategoryDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.title = '',
    this.consumable = false,
    this.usageSpecifics,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) =>
      _$CategoryDTOFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDTOToJson(this);
}
