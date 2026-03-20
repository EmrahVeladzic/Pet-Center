import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';

import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/service_output.dart';

class AccountService {
  static Future<String?> logIn(AccountRequestDTO input) async {
    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}/api/Account/LogIn"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    final result = await ServiceOutput.fromResponse<String>(
      response,
      (json) => json as String,
    );

    return result;
  }
}
