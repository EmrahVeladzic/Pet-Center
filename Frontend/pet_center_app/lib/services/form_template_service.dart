import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class FormTemplateService {
  static Future<List<FormTemplateDTO>?> get() async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/FormTemplate",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<FormTemplateDTO>>(
        response,
        (json) => (json as List)
            .map((e) => FormTemplateDTO.fromJson(e as Map<String, dynamic>))
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
