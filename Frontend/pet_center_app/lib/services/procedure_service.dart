import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class ProcedureService {
  static Future<List<ProcedureDTO>?> get() async {
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Procedure",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<List<ProcedureDTO>>(
        response,
        (json) => (json as List)
            .map((e) => ProcedureDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }
}
