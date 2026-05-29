import 'package:pet_center_app/utils/app_config.dart';

String fromMinor(int minor, [int? discount]) {
  int disc = discount ?? 0;
  int discounted = (minor * (100 - disc) / 100).round();

  if (discounted == 0) {
    return "FREE";
  }

  return '${formatDouble(discounted / AppConfig.pricingMult)}${AppConfig.currency}';
}

int toMinor(int value) {
  return value * AppConfig.pricingMult;
}

String formatDouble(double value) {
  return value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}
