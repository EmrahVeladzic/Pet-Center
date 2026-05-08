import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class LivingConditionService {
  static Future<List<LivingConditionEntrySubDTO>?> get() async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();

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
          await ServiceOutput.fromResponse<List<LivingConditionEntrySubDTO>>(
            response,
            (json) => (json as List)
                .map(
                  (e) => LivingConditionEntrySubDTO.fromJson(
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
}
