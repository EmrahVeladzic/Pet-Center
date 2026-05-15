import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class FranchiseService {
  static Future<int?> count(String? relatedUser) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      if (relatedUser != null) {
        query['relatedUser'] = relatedUser;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Franchise/Count",
        ).replace(queryParameters: query),
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

  static Future<List<FranchiseResponseDTO>?> get(
    String? relatedUser,
    int page,
  ) async {
    apiServiceBusy = true;
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      if (relatedUser != null) {
        query['relatedUser'] = relatedUser;
      }

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Franchise",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
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

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<List<FranchiseResponseDTO>?> getAll(String? relatedUser) async {
    final pageCount = await count(relatedUser);

    if (pageCount == null) {
      return null;
    }

    List<FranchiseResponseDTO> output = [];
    final seen = <String?>{};

    for (int i = 0; i < pageCount; i++) {
      final newEntries = await get(relatedUser, i);

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
