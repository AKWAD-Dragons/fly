import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fly_networking/http_logger/log_level.dart';
import 'package:fly_networking/http_logger/logging_middleware.dart';
import 'package:fly_networking/http_middleware/http_client_with_middleware.dart';
import 'package:http/http.dart' show Response;

class APIManager {
  late HttpClientWithMiddleware _client;
  // Duration _timeout;
  // Function _timeoutFunc;
  Map<String, String> map = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptHeader: "application/json"
  };

  // APIManager({Map headerMap}){
  //   map.addAll(headerMap);
  // }

  void _setMiddleWares() {
    _client = HttpClientWithMiddleware.build(
        middlewares: [HttpLogger(logLevel: LogLevel.BODY)]);
  }

  void setHeaders(Map<String, String> headers) {
    map.addAll(headers);
  }

  Future<Response?> post(String apiPath, {required String body}) async {
    try {
      _setMiddleWares();

      Uri uri = Uri.parse(apiPath);
      if (uri.scheme == "https")
        uri = Uri.https(uri.authority, uri.path);
      else
        uri = Uri.http(uri.authority, uri.path);

      final Response response =
          await _client.post(uri, body: body, headers: map);

      return response;
    } catch (e) {
      print("post req Failed $e");
    }
  }
}
