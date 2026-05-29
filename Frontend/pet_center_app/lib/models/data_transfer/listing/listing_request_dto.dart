import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
part 'listing_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ListingRequestDTO {
  String? id;
  String currentVersion;
  String name;
  String description;
  String franchiseId;
  int priceMinor;
  ListingType type;
  ProductListingSubDTO? productListingExtension;
  MedicalListingSubDTO? medicalListingExtension;
  AnimalListingSubDTO? animalListingExtension;

  ListingRequestDTO({
    this.id,
    this.currentVersion = '',
    this.name = '',
    this.description = '',
    this.franchiseId = '',
    this.priceMinor = 0,
    this.type = ListingType.generic,
    this.productListingExtension,
    this.medicalListingExtension,
    this.animalListingExtension,
  });

  factory ListingRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$ListingRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ListingRequestDTOToJson(this);

  ListingRequestDTO copy() => ListingRequestDTO(
    id: id,
    currentVersion: currentVersion,
    name: name,
    description: description,
    franchiseId: franchiseId,
    priceMinor: priceMinor,
    type: type,
    productListingExtension: productListingExtension?.copy(),
    medicalListingExtension: medicalListingExtension?.copy(),
    animalListingExtension: animalListingExtension?.copy(),
  );
}
