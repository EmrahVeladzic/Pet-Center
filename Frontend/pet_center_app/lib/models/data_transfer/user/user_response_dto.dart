import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'user_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnnouncementSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String body;
  DateTime datePosted;

  AnnouncementSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.body = '',
    DateTime? datePosted,
  }) : datePosted = datePosted ?? DateTime.now().toUtc();

  factory AnnouncementSubDTO.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementSubDTOToJson(this);

  AnnouncementSubDTO copy() => AnnouncementSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    body: body,
  );
}

@JsonSerializable(explicitToJson: true)
class NotificationSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String? listingId;
  String title;
  String body;
  DateTime datePosted;

  NotificationSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.listingId,
    this.title = '',
    this.body = '',
    DateTime? datePosted,
  }) : datePosted = datePosted ?? DateTime.now().toUtc();

  factory NotificationSubDTO.fromJson(Map<String, dynamic> json) =>
      _$NotificationSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSubDTOToJson(this);

  NotificationSubDTO copy() => NotificationSubDTO(
    id: id,
    currentVersion: currentVersion,
    notes: notes?.map((n) => n.copy()).toList(),
    listingId: listingId,
    title: title,
    body: body,
  );
}

@JsonSerializable(explicitToJson: true)
class SuppliesSubDTO {
  String? id;
  String currentVersion;
  String kindId;
  String consumableId;
  List<NoteSubDTO>? notes;

  SuppliesSubDTO({
    this.id,
    this.currentVersion = '',
    this.kindId = '',
    this.consumableId = '',
    this.notes,
  });

  factory SuppliesSubDTO.fromJson(Map<String, dynamic> json) =>
      _$SuppliesSubDTOFromJson(json);

  Map<String, dynamic> toJson() => _$SuppliesSubDTOToJson(this);

  SuppliesSubDTO copy() => SuppliesSubDTO(
    id: id,
    currentVersion: currentVersion,
    kindId: kindId,
    consumableId: consumableId,
    notes: notes?.map((n) => n.copy()).toList(),
  );
}

@JsonSerializable(explicitToJson: true)
class UserResponseDTO {
  String? id;
  String currentVersion;
  bool matureAccount;
  String userName;
  List<NoteSubDTO>? notes;
  List<NotificationSubDTO>? notifications;
  List<SuppliesSubDTO>? userSupplies;
  List<FranchiseResponseDTO>? workplaces;
  List<IndividualResponseDTO>? ownedAnimals;
  List<String>? userWishlist;

  UserResponseDTO({
    this.id,
    this.currentVersion = '',
    this.userName = '',
    this.notes,
    this.userSupplies,
    this.notifications,
    this.matureAccount = false,
    this.ownedAnimals,
    this.workplaces,
    this.userWishlist,
  });

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDTOToJson(this);

  UserResponseDTO copy() => UserResponseDTO(
    id: id,
    currentVersion: currentVersion,
    matureAccount: matureAccount,
    userName: userName,
    notes: notes?.map((n) => n.copy()).toList(),
    notifications: notifications?.map((n) => n.copy()).toList(),
    userSupplies: userSupplies?.map((s) => s.copy()).toList(),
    workplaces: workplaces?.map((w) => w.copy()).toList(),
    ownedAnimals: ownedAnimals?.map((a) => a.copy()).toList(),
    userWishlist: userWishlist,
  );
}
