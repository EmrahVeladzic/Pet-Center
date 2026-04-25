import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class ListingService {
  static Future<ListingResponseDTO?> getById(String id) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/$id"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<ListingResponseDTO>(
        response,
        (json) => ListingResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future<CommentResponseSubDTO?> sendReview(
    String listingId,
    String text,
  ) async {
    try {
      final query = <String, String>{};
      query['comment'] = text;

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Review/$listingId",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      final result = await ServiceOutput.fromResponse<CommentResponseSubDTO>(
        response,
        (json) => CommentResponseSubDTO.fromJson(json as Map<String, dynamic>),
      );

      return result;
    } catch (ex) {
      showError(ex);
      return null;
    }
  }

  static Future deleteReview(String id) async {
    try {
      await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/Review/$id"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );
    } catch (ex) {
      showError(ex);
    }
  }
}
