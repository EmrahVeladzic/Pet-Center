// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductListingSubDTO _$ProductListingSubDTOFromJson(
  Map<String, dynamic> json,
) => ProductListingSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  productId: json['productId'] as String? ?? '',
  perListing: (json['perListing'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$ProductListingSubDTOToJson(
  ProductListingSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'productId': instance.productId,
  'perListing': instance.perListing,
};

AnimalListingSubDTO _$AnimalListingSubDTOFromJson(Map<String, dynamic> json) =>
    AnimalListingSubDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      animalId: json['animalId'] as String? ?? '',
    );

Map<String, dynamic> _$AnimalListingSubDTOToJson(
  AnimalListingSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'animalId': instance.animalId,
};

MedicalListingSubDTO _$MedicalListingSubDTOFromJson(
  Map<String, dynamic> json,
) => MedicalListingSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  procedureId: json['procedureId'] as String? ?? '',
);

Map<String, dynamic> _$MedicalListingSubDTOToJson(
  MedicalListingSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'procedureId': instance.procedureId,
};

CommentResponseSubDTO _$CommentResponseSubDTOFromJson(
  Map<String, dynamic> json,
) => CommentResponseSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  listingId: json['listingId'] as String? ?? '',
  posterId: json['posterId'] as String? ?? '',
  posterName: json['posterName'] as String? ?? '',
  contents: json['contents'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommentResponseSubDTOToJson(
  CommentResponseSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'listingId': instance.listingId,
  'posterId': instance.posterId,
  'posterName': instance.posterName,
  'contents': instance.contents,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};

AvailabilityResponseSubDTO _$AvailabilityResponseSubDTOFromJson(
  Map<String, dynamic> json,
) => AvailabilityResponseSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  facilityId: json['facilityId'] as String? ?? '',
  contact: json['contact'] as String? ?? '',
  city: json['city'] as String? ?? '',
  street: json['street'] as String? ?? '',
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AvailabilityResponseSubDTOToJson(
  AvailabilityResponseSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'facilityId': instance.facilityId,
  'contact': instance.contact,
  'city': instance.city,
  'street': instance.street,
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};

DiscountResponseSubDTO _$DiscountResponseSubDTOFromJson(
  Map<String, dynamic> json,
) => DiscountResponseSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  percentage: (json['percentage'] as num?)?.toInt() ?? 0,
  expiry: json['expiry'] == null
      ? null
      : DateTime.parse(json['expiry'] as String),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DiscountResponseSubDTOToJson(
  DiscountResponseSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'percentage': instance.percentage,
  'expiry': instance.expiry.toIso8601String(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};

ReportResponseSubDTO _$ReportResponseSubDTOFromJson(
  Map<String, dynamic> json,
) => ReportResponseSubDTO(
  id: json['id'] as String?,
  currentVersion: json['currentVersion'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  reporterId: json['reporterId'] as String? ?? '',
  listingId: json['listingId'] as String? ?? '',
  commentId: json['commentId'] as String?,
  expiry: json['expiry'] == null
      ? null
      : DateTime.parse(json['expiry'] as String),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReportResponseSubDTOToJson(
  ReportResponseSubDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentVersion': instance.currentVersion,
  'reason': instance.reason,
  'reporterId': instance.reporterId,
  'listingId': instance.listingId,
  'commentId': instance.commentId,
  'expiry': instance.expiry.toIso8601String(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};
