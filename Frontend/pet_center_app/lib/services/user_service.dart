import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/user/user_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class UserService {
  static Future<UserResponseDTO?> getSelf() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Me"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<UserResponseDTO>(
        response,
        (json) => UserResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> setEmployee(
    String userId,
    String franchiseId,
    bool hire,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['add_remove'] = hire.toString();

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/SetEmployee/$userId/$franchiseId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> getUserStatus() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Status"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<UserResponseDTO?> update(UserRequestDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/${self?.id}"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<UserResponseDTO>(
        response,
        (json) => UserResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<AnnouncementSubDTO>?> getAnnouncements() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Announcement"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<AnnouncementSubDTO>>(
        response,
        (json) => (json as List)
            .map((e) => AnnouncementSubDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<int?> countReports() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Report/Count"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as int,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<ReportResponseSubDTO>?> getReports(int page) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Report",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result =
          await ServiceOutput.fromResponse<List<ReportResponseSubDTO>>(
            response,
            (json) => (json as List)
                .map(
                  (e) =>
                      ReportResponseSubDTO.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<ReportResponseSubDTO>?> getAllReports() async {
    final pageCount = await countReports();

    if (pageCount == null) {
      return null;
    }

    List<ReportResponseSubDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await getReports(i);

      if (newEntries == null) {
        return null;
      }

      for (final ent in newEntries) {
        if (seen.add(ent.id)) {
          output.add(ent);
        }
      }
    }

    return output;
  }

  static Future<int?> count(
    bool includeExclude,
    String? userName,
    String? employedBy,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();

      query['includeExclude'] = includeExclude.toString();
      if (employedBy != null) {
        query['employedBy'] = employedBy;
      }
      if (userName != null && userName.trim() != "") {
        query['userName'] = userName;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Count",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as int,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<UserResponseDTO>?> get(
    bool includeExclude,
    String? userName,
    String? employedBy,
    int page,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      if (userName != null && userName.trim() != "") {
        query['userName'] = userName;
      }
      query['includeExclude'] = includeExclude.toString();
      if (employedBy != null) {
        query['employedBy'] = employedBy;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<UserResponseDTO>>(
        response,
        (json) => (json as List)
            .map((e) => UserResponseDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> reset() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/${self?.id}"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<String?> setWishlistTerm(String term) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{'add_remove': true.toString()};

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/SetTerm/$term",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> removeWishlistTerm(String term) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{'add_remove': false.toString()};

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/SetTerm/$term",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<AnnouncementSubDTO?> addAnnouncement(
    String announcement,
    bool userVisible,
    bool businessVisible,
    int daysValid,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{
        'user_visible': userVisible.toString(),
        'business_visible': businessVisible.toString(),
        'days_valid': daysValid.toString(),
      };

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Announcement",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'text': announcement}),
      );

      final result = await ServiceOutput.fromResponse<AnnouncementSubDTO>(
        response,
        (json) => AnnouncementSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> removeAnnouncement(String announcementId) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Announcement/$announcementId",
        ),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<NotificationSubDTO?> addNotification(
    String userId,
    String title,
    String body,
    String? franchiseId,
    String? listingId,
    int daysValid,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{'days_valid': daysValid.toString()};
      if (franchiseId != null) query['franchise_id'] = franchiseId;
      if (listingId != null) query['listing_id'] = listingId;

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Notification/$userId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': title, 'body': body}),
      );

      final result = await ServiceOutput.fromResponse<NotificationSubDTO>(
        response,
        (json) => NotificationSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> removeNotification(String notificationId) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Notification/$notificationId",
        ),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool?> setSeen(String notifId) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/Notification/Seen/$notifId",
        ),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<bool>(
        response,
        (json) => (json as Map<String, dynamic>)['value'] as bool,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }
}
