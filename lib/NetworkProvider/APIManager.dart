import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fly_networking/http_logger-1.0.0/log_level.dart';
import 'package:fly_networking/http_logger-1.0.0/logging_middleware.dart';
import 'package:fly_networking/http_middleware-1.0.0/http_client_with_middleware.dart';
import 'package:fly_networking/http_middleware-1.0.0/http_methods.dart';
import 'package:http/http.dart' show Response;

class APIManager {
  HttpClientWithMiddleware _client;
  Map<String, String> map = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptHeader: "application/json"
  };

  void _setMiddleWares() {
    if (_client == null) {
      _client = HttpClientWithMiddleware.build(middlewares: [
        HttpLogger(logLevel: LogLevel.BODY),
      ]);
    }
  }

  void setHeaders(Map<String, String> headers) {
    map.addAll(headers);
  }

  Future<Response> request(String apiPath,
      {String body, Method requestMethod = Method.POST}) async {
    try {
      _setMiddleWares();

      Uri uri = Uri.parse(apiPath);

      return await _sendRequest(requestMethod, uri, body);

    } catch (e) {
      print("Request Failed $e");
    }
  }

  Future<Response> _sendRequest(
      Method requestMethod, Uri uri, dynamic body) async {
    switch (requestMethod) {
      case Method.GET:
        return await _client.get(uri, headers: map);
      case Method.DELETE:
        return await _client.delete(uri, headers: map);
      case Method.HEAD:
        return await _client.head(uri, headers: map);
      case Method.POST:
        return await _client.post(uri, body: body, headers: map);
      case Method.PUT:
        return await _client.put(uri, body: body, headers: map);
      case Method.PATCH:
        return await _client.patch(uri, body: body, headers: map);
    }
  }
}
