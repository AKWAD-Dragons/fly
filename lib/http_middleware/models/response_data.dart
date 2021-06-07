import 'package:http/http.dart';

import '../http_methods.dart';

class ResponseData {
  String url;
  int statusCode;
  Method method;
  Map<String, String>? headers;
  String body;
  int? contentLength;
  bool isRedirect;
  bool persistentConnection;

  ResponseData({
    required this.method,
    required this.url,
    required this.statusCode,
    this.headers,
    required this.body,
    this.contentLength,
    required this.isRedirect,
    required this.persistentConnection,
  });

  factory ResponseData.fromHttpResponse(Response response) {
    return ResponseData(
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      url: response.request!.url.toString(),
      method: methodFromString(response.request!.method),
      persistentConnection: response.persistentConnection,
    );
  }
}
