// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementSubDTO _$AnnouncementSubDTOFromJson(Map<String, dynamic> json) =>
    AnnouncementSubDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      body: json['body'] as String? ?? '',
    );

Map<String, dynamic> _$AnnouncementSubDTOToJson(AnnouncementSubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'body': instance.body,
    };

NotificationSubDTO _$NotificationSubDTOFromJson(Map<String, dynamic> json) =>
    NotificationSubDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      listingId: json['listingId'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );

Map<String, dynamic> _$NotificationSubDTOToJson(NotificationSubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'listingId': instance.listingId,
      'title': instance.title,
      'body': instance.body,
    };

SuppliesSubDTO _$SuppliesSubDTOFromJson(Map<String, dynamic> json) =>
    SuppliesSubDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      kindId: json['kindId'] as String? ?? '',
      consumableId: json['consumableId'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SuppliesSubDTOToJson(SuppliesSubDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'kindId': instance.kindId,
      'consumableId': instance.consumableId,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
    };

UserResponseDTO _$UserResponseDTOFromJson(Map<String, dynamic> json) =>
    UserResponseDTO(
      id: json['id'] as String?,
      currentVersion: json['currentVersion'] as String? ?? '',
      userName: json['userName'] as String?,
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      announcements: (json['announcements'] as List<dynamic>?)
          ?.map((e) => AnnouncementSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      reports: (json['reports'] as List<dynamic>?)
          ?.map((e) => ReportResponseSubDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserResponseDTOToJson(UserResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentVersion': instance.currentVersion,
      'userName': instance.userName,
      'notes': instance.notes?.map((e) => e.toJson()).toList(),
      'announcements': instance.announcements?.map((e) => e.toJson()).toList(),
      'notifications': instance.notifications?.map((e) => e.toJson()).toList(),
      'reports': instance.reports?.map((e) => e.toJson()).toList(),
    };
