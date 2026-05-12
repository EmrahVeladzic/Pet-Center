import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/models/enums.dart';
part 'listing_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ListingResponseDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String albumId;
  List<ImageDTO> media;
  bool locked;
  String name;
  String description;
  String franchiseId;
  String contact;
  String franchiseName;
  int priceMinor;
  ListingType type;
  ProductListingSubDTO? productListingExtension;
  MedicalListingSubDTO? medicalListingExtension;
  AnimalListingSubDTO? animalListingExtension;
  DiscountResponseSubDTO? listingDiscount;
  List<AvailabilityResponseSubDTO> availability;
  List<CommentResponseSubDTO> comments;
  String? mediaCreationToken;

  ListingResponseDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.albumId = '',
    List<ImageDTO>? media,
    this.name = '',
    this.description = '',
    this.franchiseId = '',
    this.contact = '',
    this.franchiseName = '',
    this.locked = true,
    this.priceMinor = 0,
    this.type = ListingType.generic,
    this.productListingExtension,
    this.medicalListingExtension,
    this.animalListingExtension,
    this.listingDiscount,
    this.mediaCreationToken,
    List<AvailabilityResponseSubDTO>? availability,
    List<CommentResponseSubDTO>? comments,
  }) : media = media ?? [],
       availability = availability ?? [],
       comments = comments ?? [];

  factory ListingResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$ListingResponseDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ListingResponseDTOToJson(this);
}
