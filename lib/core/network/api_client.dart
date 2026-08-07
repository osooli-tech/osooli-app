import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static const baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const _timeout = Duration(seconds: 20);

  final TokenStorage _tokenStorage;
  final http.Client _http;
  final void Function()? onUnauthorized;

  ApiClient({
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    this.onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) =>
      _send('POST', path, body: body, authorized: authorized);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    };
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authorized) {
      final token = await _tokenStorage.token;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      response =
          await http.Response.fromStream(await _http.send(request).timeout(_timeout));
    } on SocketException {
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.network();
    } on http.ClientException {
      throw const ApiException.network();
    }

    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } on FormatException {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? const {};
    }

    if (response.statusCode == 401) onUnauthorized?.call();
    throw ApiException.fromResponse(response.statusCode, decoded);
  }
}
