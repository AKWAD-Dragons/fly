import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fly_networking/dio/lib/dio.dart';

class APIManager {
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

  void setHeaders(Map<String, String> headers) {
    map.addAll(headers);
  }

  Future<Response> post(
    String apiPath, {
    String body,
  }) async {
    try {
      Uri uri = Uri.parse(apiPath);
      if (uri.scheme == "https") {
        uri = Uri.https(uri.authority, uri.path);
      } else {
        uri = Uri.http(uri.authority, uri.path);
      }

      final response = await Dio()
          .post(uri.toString(), data: body, options: Options(headers: map));
      // .timeout(_timeout, onTimeout: _timeoutFunc);

      return response;
    } catch (e) {
      print("post req Failed $e");
    }
  }
}
