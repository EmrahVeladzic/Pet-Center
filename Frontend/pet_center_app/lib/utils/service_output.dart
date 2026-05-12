import 'dart:convert';
import 'dart:typed_data';
import 'app_style.dart';
import 'package:json_annotation/json_annotation.dart';
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

  static Object? _parseBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  static void _handleError(int status, Object? parsedBody) {
    if (parsedBody is Map<String, dynamic> && parsedBody.containsKey('error')) {
      showSnackbar(parsedBody['error']?.toString() ?? "Unknown error.");
      return;
    }
    if (parsedBody is Map<String, dynamic> &&
        parsedBody.containsKey('errors')) {
      final message = (parsedBody['errors'] as Map<String, dynamic>).values
          .expand((e) => (e as List?) ?? [])
          .join('\n');
      showSnackbar(message);
      return;
    }
    if (parsedBody is String && parsedBody.isNotEmpty) {
      showSnackbar(parsedBody);
      return;
    }
    showSnackbar("Unexpected error - $status.");
  }

  static bool isSuccess(http.Response response) {
    if (response.statusCode >= 400) {
      _handleError(response.statusCode, _parseBody(response));
    }
    return response.statusCode < 400;
  }

  static Future<Uint8List?> fromBytes(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes.isEmpty ? null : response.bodyBytes;
    }
    _handleError(response.statusCode, _parseBody(response));
    return null;
  }

  static Future<T?> fromResponse<T>(
    http.Response response,
    T Function(Object? json) fromJsonT,
  ) async {
    final parsed = _parseBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return fromJsonT(parsed);
      } catch (_) {
        showSnackbar("Invalid server response.");
        return null;
      }
    }
    _handleError(response.statusCode, parsed);
    return null;
  }
}
