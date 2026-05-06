import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
part 'user_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnnouncementSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String body;

  AnnouncementSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.body = '',
  });

  factory AnnouncementSubDTO.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$AnnouncementSubDTOToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NotificationSubDTO {
  String? id;
  String currentVersion;
  List<NoteSubDTO>? notes;
  String? listingId;
  String title;
  String body;

  NotificationSubDTO({
    this.id,
    this.currentVersion = '',
    this.notes,
    this.listingId,
    this.title = '',
    this.body = '',
  });

  factory NotificationSubDTO.fromJson(Map<String, dynamic> json) =>
      _$NotificationSubDTOFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSubDTOToJson(this);
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
}

@JsonSerializable(explicitToJson: true)
class UserResponseDTO {
  String? id;
  String currentVersion;
  bool matureAccount;
  String? userName;
  List<NoteSubDTO>? notes;
  List<AnnouncementSubDTO>? announcements;
  List<NotificationSubDTO>? notifications;
  List<ReportResponseSubDTO>? reports;

  UserResponseDTO({
    this.id,
    this.currentVersion = '',
    this.userName,
    this.notes,
    this.announcements,
    this.notifications,
    this.reports,
    this.matureAccount = false,
  });

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDTOFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseDTOToJson(this);
}
