import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static const baseUrl = 'https://lightgreen-snake-236372.hostingersite.com/api/v1';
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

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  /// Fetches a binary file (follows the 302 redirect to storage).
  /// Returns the raw bytes; throws [ApiException] on failure.
  Future<List<int>> getBytes(String path) async {
    final token = await _tokenStorage.token;
    http.Response response;
    try {
      response = await _http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Accept': '*/*',
          'Accept-Language': 'ar',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 60));
    } on SocketException {
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.network();
    } on http.ClientException {
      throw const ApiException.network();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    if (response.statusCode == 401) onUnauthorized?.call();
    throw ApiException.fromResponse(response.statusCode, null);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) =>
      _send('POST', path, body: body, authorized: authorized);

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
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
      var uri = Uri.parse('$baseUrl$path');
      if (query != null && query.isNotEmpty) {
        uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
      }
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
