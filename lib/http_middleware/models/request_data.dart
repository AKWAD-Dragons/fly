import 'dart:convert';

import '../http_methods.dart';

class RequestData {
  Method method;
  String url;
  Map<String, String>? headers;
  dynamic body;
  Encoding? encoding;

  RequestData({
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.encoding,
  });
}
