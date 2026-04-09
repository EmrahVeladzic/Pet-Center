// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingRequestDTO _$ListingRequestDTOFromJson(Map<String, dynamic> json) =>
    ListingRequestDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      franchiseId: json['franchiseId'] as String? ?? '',
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
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
    );

Map<String, dynamic> _$ListingRequestDTOToJson(ListingRequestDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'name': instance.name,
      'description': instance.description,
      'franchiseId': instance.franchiseId,
      'priceMinor': instance.priceMinor,
      'type': _$ListingTypeEnumMap[instance.type]!,
      'productListingExtension': instance.productListingExtension?.toJson(),
      'medicalListingExtension': instance.medicalListingExtension?.toJson(),
      'animalListingExtension': instance.animalListingExtension?.toJson(),
    };

const _$ListingTypeEnumMap = {
  ListingType.generic: 0,
  ListingType.product: 1,
  ListingType.pet: 2,
  ListingType.medical: 3,
};
