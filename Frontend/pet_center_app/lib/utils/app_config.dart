import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class AppConfig {
  static late final String apiBaseUrl;
  static late final int pricingMult;
  static late final String currency;
  static late final String datetimeFormat;

  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/dart_config.json');
    final data = json.decode(jsonStr);
    final String apiBaseUrlOverride = const String.fromEnvironment(
      'API_BASE_URL',
    );
    if (apiBaseUrlOverride.isNotEmpty) {
      apiBaseUrl = apiBaseUrlOverride;
    } else {
      apiBaseUrl = data['API_BASE_URL'] ?? 'http://localhost:8080';
    }
    currency = data['CURRENCY_SYMBOL'] ?? "\$";
    pricingMult = max(data['PRICE_MINOR_MULTIPLIER'] ?? 1, 1);
    datetimeFormat = (data['DATE_TIME_FORMAT'] ?? 'dd.MM.yyyy HH:mm');
  }
}
