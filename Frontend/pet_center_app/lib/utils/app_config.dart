import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static late final String apiBaseUrl;

  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/dart_config.json');
    final data = json.decode(jsonStr);
    apiBaseUrl = data['API_BASE_URL'] ?? 'http://localhost:5000';
  }
}
