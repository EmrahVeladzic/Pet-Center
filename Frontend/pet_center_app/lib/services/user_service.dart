import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/user/user_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/services/static_data_service.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class UserService {
  static Future<UserResponseDTO?> getSelf() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/Me"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<UserResponseDTO>(
        response,
        (json) => UserResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<UserResponseDTO?> update(UserRequestDTO input) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/${self?.id}"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<UserResponseDTO>(
        response,
        (json) => UserResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<bool> reset() async {
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/User/${self?.id}"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      return false;
    }
  }
}
