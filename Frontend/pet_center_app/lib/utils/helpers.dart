import 'package:intl/intl.dart';
import 'package:pet_center_app/utils/app_config.dart';

bool validGuid(String? id) {
  return (id != null &&
      id != "" &&
      id != "00000000-0000-0000-0000-000000000000");
}

String formatDate(DateTime input, [bool dateOnly = false]) {
  String dtFormat = AppConfig.datetimeFormat;

  if (dateOnly) {
    dtFormat = dtFormat
        .replaceAll(RegExp(r'[:\s]*[Hms][:\s]*|[\s]*[aA][\s]*'), '')
        .replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '')
        .trim();
  }

  return DateFormat(dtFormat).format(input.toLocal());
}
