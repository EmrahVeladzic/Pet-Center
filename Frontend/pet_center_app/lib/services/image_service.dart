import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/image_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

class ImageService {
  static Future<Uint8List?> get(String? token) async {
    apiServiceBusy = true;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Image"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/octet-stream',
          'X-File-Token': token ?? '',
        },
      );

      final result = await ServiceOutput.fromBytes(response);

      apiServiceBusy = false;
      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<ImageDTO?> post(String? token, Uint8List? data) async {
    apiServiceBusy = true;
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Image"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/octet-stream',
          'Accept': 'application/json',
          'X-File-Token': token ?? '',
        },
        body: data,
      );

      final result = ServiceOutput.fromResponse<ImageDTO>(
        response,
        (json) => ImageDTO.fromJson(json as Map<String, dynamic>),
      );
      apiServiceBusy = false;

      return result;
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return null;
    }
  }

  static Future<bool> delete(String? token) async {
    apiServiceBusy = true;
    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.apiBaseUrl}/api/Image"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'X-File-Token': token ?? '',
        },
      );

      apiServiceBusy = false;
      return ServiceOutput.isSuccess(response);
    } catch (ex) {
      showError(ex);
      apiServiceBusy = false;
      return false;
    }
  }
}
