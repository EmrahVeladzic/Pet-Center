import 'dart:convert';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/utils/app_style.dart';

class JwtData {
  final String username;
  final String userId;
  final Access role;
  final bool verified;
  final DateTime expiry;

  JwtData.fromJson(Map<String, dynamic> json)
    : username =
          json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
      userId =
          json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'],
      role = fromClaim(
        json['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'],
      ),
      verified = json['verified'] == 'true',
      expiry = DateTime.fromMillisecondsSinceEpoch((json['exp'] as int) * 1000);
}

JwtData? userToken;
String? rawToken;

void parseJwt(String? token) {
  try {
    if (token == null) {
      showSnackbar("No token provided.");
      userToken = null;
      rawToken = null;
      return;
    }
    final parts = token.split('.');
    if (parts.length != 3) {
      showSnackbar("Invalid token.");
      userToken = null;
      rawToken = null;
      return;
    }

    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    rawToken = token;
    userToken = JwtData.fromJson(jsonDecode(decoded));
  } catch (e) {
    showSnackbar("Token parsing failure.");
    userToken = null;
    rawToken = null;
  }
}
