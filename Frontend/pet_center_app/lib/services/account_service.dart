import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class AccountService {
  static Future<String?> logIn(AccountRequestDTO input) async {
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
  }

  static Future<AccountResponseDTO?> register(AccountRequestDTO input) async {
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
  }

  static Future<String?> requestVerification() async {
    final response = await http.get(
      Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestVerification"),
      headers: {'Authorization': 'Bearer $rawToken'},
    );

    final result = await ServiceOutput.fromResponse<String>(
      response,
      (json) => json as String,
    );

    return result;
  }

  static Future<String?> verify(int code) async {
    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}/api/Account/Verify/$code"),
      headers: {'Authorization': 'Bearer $rawToken'},
    );

    final result = await ServiceOutput.fromResponse<String>(
      response,
      (json) => json as String,
    );

    return result;
  }
}
