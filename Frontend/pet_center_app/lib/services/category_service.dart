import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/category_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class CategoryService {
  static Future<List<CategoryDTO>?> get(bool? consumable) async {
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();
      if (consumable != null) {
        query['consumable'] = consumable.toString();
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Category",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<List<CategoryDTO>>(
        response,
        (json) => (json as List)
            .map((e) => CategoryDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }
}
