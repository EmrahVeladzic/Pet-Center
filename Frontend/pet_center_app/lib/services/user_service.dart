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
    apiServiceBusy = true;
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<String?> setEmployee(
    String userId,
    String franchiseId,
    bool hire,
  ) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['add_remove'] = hire.toString();

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/User/SetEmployee/$userId/$franchiseId",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<String?> getUserStatus() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Status"),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<UserResponseDTO?> update(UserRequestDTO input) async {
    apiServiceBusy = true;
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<AnnouncementSubDTO>?> getAnnouncements() async {
    apiServiceBusy = true;
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<ReportResponseSubDTO>?> getReports() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Report"),
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<int?> count(
    bool includeExclude,
    String? userName,
    String? employedBy,
  ) async {
    apiServiceBusy = true;
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
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => json as int,
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<UserResponseDTO>?> get(
    bool includeExclude,
    String? userName,
    String? employedBy,
    int page,
  ) async {
    apiServiceBusy = true;
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<bool> reset() async {
    apiServiceBusy = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/${self?.id}"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return false;
    }
  }
}
