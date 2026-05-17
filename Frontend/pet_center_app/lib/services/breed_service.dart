import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class BreedService {
  static Future<int?> count(
    bool adoptionPurposes,
    bool incomplete,
    String? kindId,
  ) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = 0.toString();
      query['adoptionPurposes'] = adoptionPurposes.toString();
      query['incomplete'] = incomplete.toString();
      if (kindId != null) {
        query['kindId'] = kindId;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Breed/Count",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
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

  static Future<List<BreedDTO>?> get(
    int page,
    bool adoptionPurposes,
    bool incomplete,
    String? kindId,
  ) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      query['adoptionPurposes'] = adoptionPurposes.toString();
      query['incomplete'] = incomplete.toString();
      if (kindId != null) {
        query['kindId'] = kindId;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Breed",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<BreedDTO>>(
        response,
        (json) => (json as List)
            .map((e) => BreedDTO.fromJson(e as Map<String, dynamic>))
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
