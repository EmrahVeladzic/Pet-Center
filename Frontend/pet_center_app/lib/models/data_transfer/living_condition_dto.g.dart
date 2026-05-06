// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'living_condition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivingConditionEntrySubDTO _$LivingConditionEntrySubDTOFromJson(
  Map<String, dynamic> json,
) => LivingConditionEntrySubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  userId: json['userId'] as String? ?? '',
  fieldId: json['fieldId'] as String? ?? '',
  answer: json['answer'] as bool? ?? false,
);

Map<String, dynamic> _$LivingConditionEntrySubDTOToJson(
  LivingConditionEntrySubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'userId': instance.userId,
  'fieldId': instance.fieldId,
  'answer': instance.answer,
};

LivingConditionFieldDTO _$LivingConditionFieldDTOFromJson(
  Map<String, dynamic> json,
) => LivingConditionFieldDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String? ?? '',
  investmentEffect: (json['investmentEffect'] as num?)?.toDouble() ?? 0.0,
  territoryEffect: (json['territoryEffect'] as num?)?.toDouble() ?? 0.0,
  pricingEffect: (json['pricingEffect'] as num?)?.toDouble() ?? 0.0,
  longevityEffect: (json['longevityEffect'] as num?)?.toDouble() ?? 0.0,
  cohabitationEffect: (json['cohabitationEffect'] as num?)?.toDouble() ?? 0.0,
  entry: json['entry'] == null
      ? null
      : LivingConditionEntrySubDTO.fromJson(
          json['entry'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$LivingConditionFieldDTOToJson(
  LivingConditionFieldDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'investmentEffect': instance.investmentEffect,
  'territoryEffect': instance.territoryEffect,
  'pricingEffect': instance.pricingEffect,
  'longevityEffect': instance.longevityEffect,
  'cohabitationEffect': instance.cohabitationEffect,
  'entry': instance.entry?.toJson(),
};
