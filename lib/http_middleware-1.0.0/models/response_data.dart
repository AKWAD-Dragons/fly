import 'dart:convert';
import 'package:fly_networking/http_middleware-1.0.0/http_methods.dart';
import 'package:http/http.dart';

class ResponseData {
  String url;
  int statusCode;
  Method method;
  Map<String, String> headers;
  String body;
  int contentLength;
  bool isRedirect;
  bool persistentConnection;

  ResponseData({
    this.method,
    this.url,
    this.statusCode,
    this.headers,
    this.body,
    this.contentLength,
    this.isRedirect,
    this.persistentConnection,
  });

  factory ResponseData.fromHttpResponse(Response response) {
    return ResponseData(
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      url: response.request.url.toString(),
      method: methodFromString(response.request.method),
      persistentConnection: response.persistentConnection,
    );
  }
}
