import 'dart:convert';

import 'package:fly_networking/http_logger-1.0.0/log_level.dart';
import 'package:fly_networking/http_middleware-1.0.0/models/request_data.dart';
import 'package:fly_networking/http_middleware-1.0.0/models/response_data.dart';

class Logger {
  final LogLevel logLevel;

  Logger({
    this.logLevel,
  });

  void logRequest({RequestData data}) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    String method = data.method.toString().split(".")[1];

    int bodyInBytes =
        data.body != null ? (utf8.encode(data.body.toString()).length) : 0;

    if (logLevel == LogLevel.BASIC) {
      print("--> ${method} ${data
          .url} (${bodyInBytes}-byte Body)");
      return;
    }

    bool logBody = logLevel == LogLevel.BODY;
    bool logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      print("--> ${data.method.toString().split(".")[1]} ${data
          .url}");

      print("HEADERS:");
      Map<String, String> headers = data.headers;
      if (headers == null || headers.length == 0) {
        print("Request has no headers.");
      } else {
        StringBuffer headersBuffer = StringBuffer();
        headers.forEach((key, value) => headersBuffer.write("$key: $value\n"));
        print(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        print("BODY:");
        if (data.body == null) {
          print("Request has no boy.");
        } else {
          print(data.body);
        }
      }
    }

    print("--> END ${method}\n");
  }

  void logResponse({ResponseData data}) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    if (logLevel == LogLevel.BASIC) {
      print("<-- ${data.statusCode} (${data.contentLength}-byte Body)");
      return;
    }

    String method = data.method.toString().split(".")[1];

    print("<-- ${method} ${data.statusCode}");

    bool logBody = logLevel == LogLevel.BODY;
    bool logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      print("URL: ${data.url}");
      print("HEADERS:");
      Map<String, String> headers = data.headers;
      if (headers == null || headers.length == 0) {
        print("Request has no headers.");
      } else {
        StringBuffer headersBuffer = StringBuffer();
        headers.forEach((key, value) => headersBuffer.write("$key: $value\n"));
        print(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        print("BODY:");
        if (data.body == null) {
          print("Request has no boy.");
        } else {
          print(data.body);
        }
      }
    }

    print("<-- END HTTP");
  }
}
