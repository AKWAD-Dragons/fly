import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;

class WebAPIManager {
  Duration _timeout;
  Function _timeoutFunc;
  Map<String, String> map = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptHeader: "application/json"
  };

  void setTimeOut(Duration duration, {Function onTimeOut}) {
    _timeout = duration;
    if (onTimeOut != null) _timeoutFunc = onTimeOut;
  }

  // APIManager({Map headerMap}){
  //   map.addAll(headerMap);
  // }

  void _setMiddleWares() {}

  void setHeaders(Map<String, String> headers) {
    map.addAll(headers);
  }

  Future<http.Response> post(
      String apiPath, {
        String body,
      }) async {
    try {
      _setMiddleWares();

      Uri uri = Uri.parse(apiPath);
      if (uri.scheme == "https") {
        uri = Uri.https(uri.authority, uri.path);
      } else {
        uri = Uri.http(uri.authority, uri.path);
      }

      final response = await http.post(uri, body: body, headers: map);
      // .timeout(_timeout, onTimeout: _timeoutFunc);

      return response;
    } catch (e) {
      print("post req Failed $e");
    }
  }
}
