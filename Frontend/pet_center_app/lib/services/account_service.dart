import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class AccountService {
  static Future<String?> logIn(AccountRequestDTO input) async {
    apiServiceBusy = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/LogIn"),
        headers: {'Content-Type': 'application/json', 'Accept': 'text/plain'},
        body: jsonEncode(input.toJson()),
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

  static Future<AccountResponseDTO?> register(AccountRequestDTO input) async {
    apiServiceBusy = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<AccountResponseDTO>(
        response,
        (json) => AccountResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<AccountResponseDTO?> update(AccountRequestDTO input) async {
    apiServiceBusy = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/${self?.id}"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<AccountResponseDTO>(
        response,
        (json) => AccountResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<String?> forgotPassword(String contact) async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account/ForgotPassword/$contact",
        ),
        headers: {'Accept': 'text/plain'},
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

  static Future<String?> requestTransfer() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestTransfer"),
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

  static Future<String?> transferAccount(int oldCode, int newCode) async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account/Transfer/$oldCode/$newCode",
        ),
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

  static Future<String?> requestVerification() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestVerification"),
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

  static Future<String?> verify(int code) async {
    apiServiceBusy = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/Verify/$code"),
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

  static Future<String?> setRole(String id, Access role) async {
    apiServiceBusy = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/SetRole/$id/$role"),
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

  static Future<bool> logOut() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/LogOut"),
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

  static Future<bool> delete(String id) async {
    apiServiceBusy = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/$id"),
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
