import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/screens/login_register.dart';
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
Access role = Access.user;

Timer? _expiryTimer;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void clearToken() {
  _expiryTimer?.cancel();
  _expiryTimer = null;
  rawToken = null;
  userToken = null;
  role = Access.user;
}

void _scheduleExpiry(DateTime expiry) {
  _expiryTimer?.cancel();

  final delay = expiry.difference(DateTime.now());

  if (delay.isNegative) {
    _handleExpiry();
    return;
  }

  _expiryTimer = Timer(delay, _handleExpiry);
}

void _handleExpiry() {
  clearToken();
  StaticAndUserDataService.clearObtainedData();

  final state = navigatorKey.currentState;
  final context = navigatorKey.currentContext;

  if (state == null || context == null) {
    return;
  }

  state.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => CredentialsScreen()),
    (route) => false,
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Session expired."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

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
    role = userToken?.role ?? Access.user;

    _scheduleExpiry(userToken!.expiry);
  } catch (e) {
    showSnackbar("Token parsing failure.");
    userToken = null;
    rawToken = null;
  }
}
