import 'package:pet_center_app/utils/app_config.dart';

String fromMinor(int minor) {
  return '${formatDouble(minor / AppConfig.pricingMult)} ${AppConfig.currency}';
}

int toMinor(int value) {
  return value * AppConfig.pricingMult;
}

String formatDouble(double value) {
  return value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}
