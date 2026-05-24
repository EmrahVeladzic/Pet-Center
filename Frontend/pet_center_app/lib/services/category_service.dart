import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class CategoryService {
  static Future<int?> count() async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category/Count"),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => json as int,
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<CategoryDTO>?> get(int page) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Category",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<CategoryDTO>>(
        response,
        (json) => (json as List)
            .map((e) => CategoryDTO.fromJson(e as Map<String, dynamic>))
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

  static Future<List<CategoryDTO>?> getAll() async {
    final pageCount = await count();

    if (pageCount == null) {
      return null;
    }

    List<CategoryDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await get(i);

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

  static Future<bool> delete(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category/$id"),
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

  static Future<CategoryDTO?> post(CategoryDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<CategoryDTO>(
        response,
        (json) => CategoryDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<CategoryDTO?> put(String id, CategoryDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category/$id"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<CategoryDTO>(
        response,
        (json) => CategoryDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<UsageSubDTO?> setUsageEstimate(
    String categoryId,
    String kindId,
    AnimalScale? scale,
    int mass,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['mass_grams'] = mass.toString();
      if (scale != null) {
        query['scale'] = scale.value.toString();
      }

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Category/Usage/$categoryId/$kindId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<UsageSubDTO>(
        response,
        (json) => UsageSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> removeUsageEstimate(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category/Usage/$id"),
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

  static Future<SuppliesSubDTO?> trackSupplies(
    String categoryId,
    String kindId,
    int mass,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['mass_grams'] = mass.toString();

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Category/Supplies/$categoryId/$kindId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<SuppliesSubDTO>(
        response,
        (json) => SuppliesSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> stopTracking(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Category/Supplies/$id"),
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
}
