// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingResponseDTO _$ListingResponseDTOFromJson(Map<String, dynamic> json) =>
    ListingResponseDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      albumId: json['albumId'] as String? ?? '',
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => ImageDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      franchiseId: json['franchiseId'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      franchiseName: json['franchiseName'] as String? ?? '',
      locked: json['locked'] as bool? ?? true,
      full: json['full'] as bool? ?? true,
      approved: json['approved'] as bool? ?? false,
      visible: json['visible'] as bool? ?? false,
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      posted: json['posted'] == null
          ? null
          : DateTime.parse(json['posted'] as String),
      type:
          $enumDecodeNullable(_$ListingTypeEnumMap, json['type']) ??
          ListingType.generic,
      productListingExtension: json['productListingExtension'] == null
          ? null
          : ProductListingSubDTO.fromJson(
              json['productListingExtension'] as Map<String, dynamic>,
            ),
      medicalListingExtension: json['medicalListingExtension'] == null
          ? null
          : MedicalListingSubDTO.fromJson(
              json['medicalListingExtension'] as Map<String, dynamic>,
            ),
      animalListingExtension: json['animalListingExtension'] == null
          ? null
          : AnimalListingSubDTO.fromJson(
              json['animalListingExtension'] as Map<String, dynamic>,
            ),
      listingDiscount: json['listingDiscount'] == null
          ? null
          : DiscountResponseSubDTO.fromJson(
              json['listingDiscount'] as Map<String, dynamic>,
            ),
      mediaCreationToken: json['mediaCreationToken'] as String?,
      availability: (json['availability'] as List<dynamic>?)
          ?.map(
            (e) =>
                AvailabilityResponseSubDTO.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map(
            (e) => CommentResponseSubDTO.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$ListingResponseDTOToJson(ListingResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'albumId': instance.albumId,
      'media': instance.media.map((e) => e.toJson()).toList(),
      'locked': instance.locked,
      'full': instance.full,
      'name': instance.name,
      'description': instance.description,
      'franchiseId': instance.franchiseId,
      'contact': instance.contact,
      'franchiseName': instance.franchiseName,
      'approved': instance.approved,
      'visible': instance.visible,
      'priceMinor': instance.priceMinor,
      'type': _$ListingTypeEnumMap[instance.type]!,
      'productListingExtension': instance.productListingExtension?.toJson(),
      'medicalListingExtension': instance.medicalListingExtension?.toJson(),
      'animalListingExtension': instance.animalListingExtension?.toJson(),
      'listingDiscount': instance.listingDiscount?.toJson(),
      'availability': instance.availability.map((e) => e.toJson()).toList(),
      'comments': instance.comments.map((e) => e.toJson()).toList(),
      'mediaCreationToken': instance.mediaCreationToken,
      'posted': instance.posted.toIso8601String(),
    };

const _$ListingTypeEnumMap = {
  ListingType.generic: 0,
  ListingType.product: 1,
  ListingType.pet: 2,
  ListingType.medical: 3,
};
