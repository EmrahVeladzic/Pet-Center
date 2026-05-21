import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/listing/listing_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class ListingService {
  static Future<int?> count(
    ListingType type,
    String relevantId,
    OrderingMethod orderBy,
    bool showApprovedAndPending,
    String kindSpecific,
    String breedSpecific,
    bool sexSpecific,
    AnimalScale scaleSpecific,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{
        'type': type.value.toString(),
        'relevantId': relevantId,
        'orderBy': orderBy.value.toString(),
        'showApprovedAndPending': showApprovedAndPending.toString(),
        'kindSpecific': kindSpecific,
        'breedSpecific': breedSpecific,
        'sexSpecific': sexSpecific.toString(),
        'scaleSpecific': scaleSpecific.value.toString(),
      };

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Count",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken', 'Accept': 'text/plain'},
      );

      final result = await ServiceOutput.fromResponse<int>(
        response,
        (json) => (json as int),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<List<ListingResponseDTO>?> get(
    int page,
    ListingType type,
    String relevantId,
    OrderingMethod orderBy,
    bool showApprovedAndPending,
    String kindSpecific,
    String breedSpecific,
    bool sexSpecific,
    AnimalScale scaleSpecific,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{
        'page': page.toString(),
        'type': type.value.toString(),
        'relevantId': relevantId,
        'orderBy': orderBy.value.toString(),
        'showApprovedAndPending': showApprovedAndPending.toString(),
        'kindSpecific': kindSpecific,
        'breedSpecific': breedSpecific,
        'sexSpecific': sexSpecific.toString(),
        'scaleSpecific': scaleSpecific.value.toString(),
      };

      final response = await http.get(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<List<ListingResponseDTO>>(
        response,
        (json) => (json as List)
            .map((e) => ListingResponseDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<ListingResponseDTO?> getById(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/$id"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<ListingResponseDTO>(
        response,
        (json) => ListingResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<ReportResponseSubDTO?> reportMisuse(
    String listingId,
    String reason, [
    String? commentId,
  ]) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['reason'] = reason;
      if (commentId != null) {
        query['comment_id'] = commentId;
      }

      final response = await http.post(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Report/$listingId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<ReportResponseSubDTO>(
        response,
        (json) => ReportResponseSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<CommentResponseSubDTO?> sendReview(
    String listingId,
    String text,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{};
      query['comment'] = text;

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Review/$listingId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<CommentResponseSubDTO>(
        response,
        (json) => CommentResponseSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/$id"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<bool> deleteReview(String id) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/Review/$id"),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<ListingResponseDTO?> post(ListingRequestDTO input) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<ListingResponseDTO>(
        response,
        (json) => ListingResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<ListingResponseDTO?> put(
    ListingRequestDTO input,
    String id,
  ) async {
    apiServiceBusy.value = true;
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Listing/$id"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      final result = await ServiceOutput.fromResponse<ListingResponseDTO>(
        response,
        (json) => ListingResponseDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> evaluate(String id, bool approve, String note) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{
        'approve': approve.toString(),
        'note': note,
      };

      final response = await http.post(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Evaluate/$id",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<DiscountResponseSubDTO?> setDiscount(
    String id,
    int percentage,
    int daysValid,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{
        'percentage': percentage.toString(),
        'days_valid': daysValid.toString(),
      };

      final response = await http.post(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Discount/$id",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<DiscountResponseSubDTO>(
        response,
        (json) => DiscountResponseSubDTO.fromJson(json as Map<String, dynamic>),
      );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }

  static Future<bool> setVisibility(String id, bool visible) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{'visible': visible.toString()};

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Visibility/$id",
        ).replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $rawToken'},
      );

      apiServiceBusy.value = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return false;
    }
  }

  static Future<AvailabilityResponseSubDTO?> setAvailability(
    String listingId,
    String facilityId,
    bool addRemove,
  ) async {
    apiServiceBusy.value = true;
    try {
      final query = <String, String>{'add_remove': addRemove.toString()};

      final response = await http.put(
        Uri.parse(
          "${AppConfig.apiBaseUrl}/api/Listing/Available/$listingId/$facilityId",
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result =
          await ServiceOutput.fromResponse<AvailabilityResponseSubDTO>(
            response,
            (json) => AvailabilityResponseSubDTO.fromJson(
              json as Map<String, dynamic>,
            ),
          );

      apiServiceBusy.value = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy.value = false;
      return null;
    }
  }
}
