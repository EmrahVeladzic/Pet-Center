import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:http/http.dart' as http;

enum HttpCode {
  @JsonValue(200)
  ok,
  @JsonValue(201)
  created,
  @JsonValue(204)
  noContent,

  @JsonValue(400)
  badRequest,
  @JsonValue(401)
  unauthorized,
  @JsonValue(403)
  forbidden,
  @JsonValue(404)
  notFound,
  @JsonValue(409)
  conflict,
  @JsonValue(429)
  tooManyRequests,

  @JsonValue(500)
  internalError,
  @JsonValue(501)
  notImplemented,
}

extension HttpCodeExtension on HttpCode {
  int get value {
    switch (this) {
      case HttpCode.ok:
        return 200;
      case HttpCode.created:
        return 201;
      case HttpCode.noContent:
        return 204;
      case HttpCode.badRequest:
        return 400;
      case HttpCode.unauthorized:
        return 401;
      case HttpCode.forbidden:
        return 403;
      case HttpCode.notFound:
        return 404;
      case HttpCode.conflict:
        return 409;
      case HttpCode.tooManyRequests:
        return 429;
      case HttpCode.internalError:
        return 500;
      case HttpCode.notImplemented:
        return 501;
    }
  }
}

class ServiceOutput<T> {
  final int statusCode;
  final T? body;
  final String? errorMessage;

  ServiceOutput({required this.statusCode, this.body, this.errorMessage});

  bool get isSuccess => statusCode < 400;

  static Future<T?> fromResponse<T>(
    http.Response response,
    T Function(Object? json) fromJsonT,
  ) async {
    final status = response.statusCode;

    Object? parsedBody;
    if (response.body.isNotEmpty) {
      try {
        parsedBody = jsonDecode(response.body);
      } catch (e) {
        parsedBody = response.body;
      }
    }

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      return fromJsonT(parsedBody);
    }

    if (parsedBody is Map<String, dynamic> && parsedBody.containsKey('error')) {
      final msg = parsedBody['error']?.toString();
      rootScaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text(msg ?? "Unknown error.")),
      );
      return null;
    }

    if (parsedBody is Map<String, dynamic> &&
        parsedBody.containsKey('errors')) {
      final message = (parsedBody['errors'] as Map<String, dynamic>).values
          .expand((e) => e as List)
          .join('\n');
      rootScaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
      return null;
    }

    rootScaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text("Unexpected error - $status.")),
    );
    return null;
  }
}
