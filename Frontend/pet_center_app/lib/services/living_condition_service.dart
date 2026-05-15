import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class LivingConditionService {
  static Future<int?> count() async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/LivingConditionField/Count"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => (json as int),
      );

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<LivingConditionFieldDTO>?> get(int page) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/LivingConditionField",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result =
          await ServiceOutput.fromResponse<List<LivingConditionFieldDTO>>(
            response,
            (json) => (json as List)
                .map(
                  (e) => LivingConditionFieldDTO.fromJson(
                    e as Map<String, dynamic>,
                  ),
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

  static Future<List<LivingConditionFieldDTO>?> getAll() async {
    final pageCount = await count();

    if (pageCount == null) {
      return null;
    }

    List<LivingConditionFieldDTO> output = [];
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
}
