import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class FranchiseService {
  static Future<List<FranchiseResponseDTO>?> get([String? relatedUser]) async {
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();
      if (relatedUser != null) {
        query['relatedUser'] = relatedUser;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Franchise",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result =
          await ServiceOutput.fromResponse<List<FranchiseResponseDTO>>(
            response,
            (json) => (json as List)
                .map(
                  (e) =>
                      FranchiseResponseDTO.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }
}
