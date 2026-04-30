import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class AccountService {
  static Future<String?> logIn(AccountRequestDTO input) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/LogIn"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<AccountResponseDTO?> register(AccountRequestDTO input) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<AccountResponseDTO>(
        response,
        (json) => AccountResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<String?> forgotPassword(String contact) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account/ForgotPassword/$contact",
        ),
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<String?> requestVerification() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestVerification"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<String?> verify(int code) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/Verify/$code"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/$id"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      return false;
    }
  }
}
