import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'living_condition_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class LivingConditionEntrySubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String userId;
  String fieldId;
  bool answer;

  LivingConditionEntrySubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.userId = '',
    this.fieldId = '',
    this.answer = false,
  });

  factory LivingConditionEntrySubDTO.fromJson(Map<String, dynamic> json) =>
      _$LivingConditionEntrySubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$LivingConditionEntrySubDTOToJson(this);

  LivingConditionEntrySubDTO copy() => LivingConditionEntrySubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    userId: userId,
    fieldId: fieldId,
    answer: answer,
  );
}

@JsonSerializable(explicitToJson: true)
class LivingConditionFieldDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String title;
  double investmentEffect;
  double territoryEffect;
  double pricingEffect;
  double longevityEffect;
  double cohabitationEffect;
  LivingConditionEntrySubDTO? entry;

  LivingConditionFieldDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.title = '',
    this.investmentEffect = 0.0,
    this.territoryEffect = 0.0,
    this.pricingEffect = 0.0,
    this.longevityEffect = 0.0,
    this.cohabitationEffect = 0.0,
    this.entry,
  });

  factory LivingConditionFieldDTO.fromJson(Map<String, dynamic> json) =>
      _$LivingConditionFieldDTOFromJson(json);

  Map<String, dynamic> toJson() => _$LivingConditionFieldDTOToJson(this);

  LivingConditionFieldDTO copy() => LivingConditionFieldDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    title: title,
    investmentEffect: investmentEffect,
    territoryEffect: territoryEffect,
    pricingEffect: pricingEffect,
    longevityEffect: longevityEffect,
    cohabitationEffect: cohabitationEffect,
    entry: entry?.copy(),
  );
}
