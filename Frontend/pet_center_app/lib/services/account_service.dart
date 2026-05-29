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
    apiServiceBusy.value = true;
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

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<AccountResponseDTO?> register(AccountRequestDTO input) async {
    apiServiceBusy.value = true;
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

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<AccountResponseDTO?> update(AccountRequestDTO input) async {
    apiServiceBusy.value = true;
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

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> forgotPassword(String contact) async {
    apiServiceBusy.value = true;
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

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> requestTransfer() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestTransfer"),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> transferAccount(int oldCode, int newCode) async {
    apiServiceBusy.value = true;
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

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> requestVerification() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/RequestVerification"),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> verify(int code) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/Verify/$code"),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<String?> setRole(String id, Access accRole) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account/SetRole/$id/${accRole.value}",
        ),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<String>(
        response,
        (json) => json as String,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> logOut() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/LogOut"),
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

  static Future<bool> delete(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Account/$id"),
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

  static Future<int?> count(Access accRole, String contact) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      if (contact.isNotEmpty) {
        query['contact'] = contact;
      }

      query['role'] = accRole.value.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account/Count",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => (json as int),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<AccountResponseDTO>?> get(
    int page,
    Access accRole,
    String contact,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      if (contact.isNotEmpty) {
        query['contact'] = contact;
      }

      query['role'] = accRole.value.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Account",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<AccountResponseDTO>>(
        response,
        (json) => (json as List)
            .map((e) => AccountResponseDTO.fromJson(e as Map<String, dynamic>))
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

  static Future<List<AccountResponseDTO>?> getAll(
    Access role,
    String contact,
  ) async {
    final pageCount = await count(role, contact);

    if (pageCount == null) {
      return null;
    }

    List<AccountResponseDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await get(i, role, contact);

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
}
