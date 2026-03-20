import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AppState extends ChangeNotifier {
  String? token;

  void setToken(String value) {
    token = value;
    notifyListeners();
  }

  bool get isVerified {
    if (token == null) {
      return false;
    }

    final decoded = JwtDecoder.decode(token!);
    final value = decoded["verified"];

    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == "true";
    }

    return false;
  }
}
