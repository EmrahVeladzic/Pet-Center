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

  ProductListingSubDTO copy() => ProductListingSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    productId: productId,
    perListing: perListing,
  );
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

  AnimalListingSubDTO copy() => AnimalListingSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    animalId: animalId,
  );
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

  MedicalListingSubDTO copy() => MedicalListingSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    procedureId: procedureId,
  );
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
  DateTime lastEditDate;

  CommentResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.listingId = '',
    this.posterId = '',
    this.posterName = '',
    this.contents = '',
    this.notes,
    DateTime? lastEditDate,
  }) : lastEditDate = lastEditDate ?? DateTime.now().toUtc();

  factory CommentResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResponseSubDTOToJson(this);

  CommentResponseSubDTO copy() => CommentResponseSubDTO(
    id: id,
    currentVersion: currentVersion,
    listingId: listingId,
    posterId: posterId,
    posterName: posterName,
    contents: contents,
    notes: notes?.map((n) => n.copy()).toList(),
  );
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

  AvailabilityResponseSubDTO copy() => AvailabilityResponseSubDTO(
    id: id,
    currentVersion: currentVersion,
    facilityId: facilityId,
    contact: contact,
    city: city,
    street: street,
    notes: notes?.map((n) => n.copy()).toList(),
  );
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

  DiscountResponseSubDTO copy() => DiscountResponseSubDTO(
    id: id,
    currentVersion: currentVersion,
    percentage: percentage,
    expiry: expiry,
    notes: notes?.map((n) => n.copy()).toList(),
  );
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
  DateTime datePosted;

  ReportResponseSubDTO({
    this.id,
    this.currentVersion = '',
    this.reason = '',
    this.reporterId = '',
    this.listingId = '',
    this.commentId,
    DateTime? expiry,
    this.notes,
    DateTime? datePosted,
  }) : expiry = expiry ?? DateTime.now().toUtc(),
       datePosted = datePosted ?? DateTime.now().toUtc();

  factory ReportResponseSubDTO.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ReportResponseSubDTOToJson(this);

  ReportResponseSubDTO copy() => ReportResponseSubDTO(
    id: id,
    currentVersion: currentVersion,
    reason: reason,
    reporterId: reporterId,
    listingId: listingId,
    commentId: commentId,
    expiry: expiry,
    notes: notes?.map((n) => n.copy()).toList(),
  );
}
