import 'dart:convert';

import '../http_methods.dart';

class RequestData {
  Method method;
  String url;
  Map<String, String> headers;
  dynamic body;
  Encoding encoding;

  RequestData({
    this.method,
    this.url,
    this.headers,
    this.body,
    this.encoding,
  });
}
