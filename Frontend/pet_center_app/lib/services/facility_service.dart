import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/service_output.dart';

class FacilityService {
  static Future<int?> count(String franchiseId) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};

      query['franchiseId'] = franchiseId;

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Facility/Count",
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

  static Future<FacilityDTO?> put(FacilityDTO input, String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Facility/$id"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<FacilityDTO>(
        response,
        (json) => FacilityDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<FacilityDTO?> post(FacilityDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Facility"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<FacilityDTO>(
        response,
        (json) => FacilityDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> delete(String facilityId) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Facility/$facilityId"),
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

  static Future<List<FacilityDTO>?> get(String franchiseId, int page) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();

      query['franchiseId'] = franchiseId;

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Facility",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<FacilityDTO>>(
        response,
        (json) => (json as List)
            .map((e) => FacilityDTO.fromJson(e as Map<String, dynamic>))
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

  static Future<List<FacilityDTO>?> getAll(String franchiseId) async {
    final pageCount = await count(franchiseId);

    if (pageCount == null) {
      return null;
    }

    List<FacilityDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await get(franchiseId, i);

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
