import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/providers/app_state.dart';

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

final AppState appState = AppState();

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

JwtData? get userToken => appState.userToken;
String? get rawToken => appState.rawToken;
Access get role => appState.role;

void clearToken() => appState.clearToken();
void parseJwt(String? token) => appState.parseJwt(token);
