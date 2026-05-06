import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';

part 'sub_dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductListingSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String productId;
  int perListing;

  ProductListingSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.productId = '',
    this.perListing = 1,
  });

  factory ProductListingSubDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductListingSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ProductListingSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnimalListingSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String animalId;

  AnimalListingSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.animalId = '',
  });

  factory AnimalListingSubDTO.fromJson(Map<String, dynamic> json) =>
      _$AnimalListingSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalListingSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MedicalListingSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String procedureId;

  MedicalListingSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.procedureId = '',
  });

  factory MedicalListingSubDTO.fromJson(Map<String, dynamic> json) =>
      _$MedicalListingSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalListingSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CommentResponseSubDTO {
  String? id;
  String currentVersion;
  String listingId;
  String posterId;
  String posterName;
  String contents;
  List<NoteSubDTO>? notes;

  CommentResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.listingId = '',
    this.posterId = '',
    this.posterName = '',
    this.contents = '',
    this.notes,
  });

  factory CommentResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$CommentResponseSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AvailabilityResponseSubDTO {
  String? id;
  String currentVersion;
  String facilityId;
  String contact;
  String city;
  String street;
  List<NoteSubDTO>? notes;

  AvailabilityResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.facilityId = '',
    this.contact = '',
    this.city = '',
    this.street = '',
    this.notes,
  });

  factory AvailabilityResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityResponseSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityResponseSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DiscountResponseSubDTO {
  String? id;
  String currentVersion;
  int percentage;
  DateTime expiry;
  List<NoteSubDTO>? notes;

  DiscountResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.percentage = 0,
    DateTime? expiry,
    this.notes,
  }) : expiry = expiry ?? DateTime.now().toUtc();

  factory DiscountResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$DiscountResponseSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$DiscountResponseSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReportResponseSubDTO {
  String? id;
  String currentVersion;
  String reason;
  String reporterId;
  String listingId;
  String? commentId;
  DateTime expiry;
  List<NoteSubDTO>? notes;

  ReportResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.reason = '',
    this.reporterId = '',
    this.listingId = '',
    this.commentId,
    DateTime? expiry,
    this.notes,
  }) : expiry = expiry ?? DateTime.now().toUtc();

  factory ReportResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ReportResponseSubDTOToJson(this);
}
