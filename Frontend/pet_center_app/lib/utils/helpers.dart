import 'package:intl/intl.dart';
import 'package:pet_center_app/utils/app_config.dart';

bool validGuid(String? id) {
  return (id != null &&
      id != "" &&
      id != "00000000-0000-0000-0000-000000000000");
}

String formatDate(DateTime input) {
  return DateFormat(AppConfig.datetimeFormat).format(input.toLocal());
}
