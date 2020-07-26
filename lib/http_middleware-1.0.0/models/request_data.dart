import 'dart:convert';

import 'package:fly_networking/http_middleware-1.0.0/http_methods.dart';



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
