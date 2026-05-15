import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/category_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class CategoryService {
  static Future<int?> count(bool? consumable) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      if (consumable != null) {
        query['consumable'] = consumable.toString();
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Category/Count",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
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

  static Future<List<CategoryDTO>?> get(bool? consumable, int page) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      if (consumable != null) {
        query['consumable'] = consumable.toString();
      }

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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<CategoryDTO>?> getAll(bool? consumable) async {
    final pageCount = await count(consumable);

    if (pageCount == null) {
      return null;
    }

    List<CategoryDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await get(consumable, i);

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
