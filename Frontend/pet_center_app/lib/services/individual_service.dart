import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:pet_center_app/models/data_transfer/individual/individual_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class IndividualService {
  static Future<int?> count(String? fromFranchise) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};

      if (fromFranchise != null) {
        query['fromFranchise'] = fromFranchise;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Individual/Count",
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

  static Future<IndividualResponseDTO?> put(
    IndividualRequestDTO input,
    String id,
  ) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Individual/$id"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<IndividualResponseDTO>(
        response,
        (json) => IndividualResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<IndividualResponseDTO?> post(IndividualRequestDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Individual"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<IndividualResponseDTO>(
        response,
        (json) => IndividualResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Individual/$id"),
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

  static Future<List<IndividualResponseDTO>?> get(
    String? fromFranchise,
    int page,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();

      if (fromFranchise != null) {
        query['fromFranchise'] = fromFranchise;
      }
      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Individual",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result =
          await ServiceOutput.fromResponse<List<IndividualResponseDTO>>(
            response,
            (json) => (json as List)
                .map(
                  (e) =>
                      IndividualResponseDTO.fromJson(e as Map<String, dynamic>),
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

  static Future<IndividualResponseDTO?> copy(
    String animalId,
    String? onBehalf,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};

      if (onBehalf != null) {
        query['on_behalf'] = onBehalf;
      }

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Individual/Copy/$animalId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<IndividualResponseDTO>(
        response,
        (json) => IndividualResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<MedicalEntrySubDTO?> medical(
    String animalId,
    String procedureId,
    int? daysSince,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};

      if (daysSince != null) {
        query['days_since'] = daysSince.toString();
      }

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Individual/Medical/$animalId/$procedureId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<MedicalEntrySubDTO>(
        response,
        (json) => MedicalEntrySubDTO.fromJson(json as Map<String, dynamic>),
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
