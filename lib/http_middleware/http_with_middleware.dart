import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'http_methods.dart';
import 'middleware_contract.dart';
import 'models/request_data.dart';
import 'models/response_data.dart';

///Class to be used by the user as a replacement for 'http' with middleware supported.
///call the `build()` constructor passing in the list of middlewares.
///Example:
///```dart
/// HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     Logger(),
/// ]);
///```
///Then call the functions you want to, on the created `http` object.
///```dart
/// http.get(...);
/// http.post(...);
/// http.put(...);
/// http.delete(...);
/// http.head(...);
/// http.patch(...);
/// http.read(...);
/// http.readBytes(...);
///```
class HttpWithMiddleware {
  List<MiddlewareContract> middlewares;

  HttpWithMiddleware._internal({required this.middlewares});

  factory HttpWithMiddleware.build(
      {required List<MiddlewareContract?> middlewares}) {
    //Remove any value that is null.
    middlewares.removeWhere((middleware) => middleware == null);

    return new HttpWithMiddleware._internal(
        middlewares: middlewares as List<MiddlewareContract>);
  }

  Future<Response> post(url,
      {Map<String, String>? headers, required body, Encoding? encoding}) {
    RequestData data = _sendInterception(
        method: Method.POST,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient<Response>((client) => client.post(Uri.parse(data.url),
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Uint8List> readBytes(url, {Map<String, String>? headers}) =>
      _withClient<Uint8List>(
          (client) => client.readBytes(url, headers: headers));

  RequestData _sendInterception(
      {required Method method,
      Encoding? encoding,
      required dynamic body,
      required String url,
      Map<String, String>? headers}) {
    RequestData data = RequestData(
      method: method,
      encoding: encoding,
      body: body,
      url: url,
      headers: headers,
    );
    middlewares.forEach((middleware) => middleware.interceptRequest(data));
    return data;
  }

  Future<T> _withClient<T>(Future<T> fn(Client client)) async {
    var client = new Client();
    try {
      T response = await fn(client);

      if (response is Response) {
        ResponseData responseData = ResponseData.fromHttpResponse(response);
        middlewares.forEach(
            (middleware) => middleware.interceptResponse(responseData));

        Response resultResponse = Response(
          responseData.body,
          responseData.statusCode,
          headers: responseData.headers ?? {},
          persistentConnection: responseData.persistentConnection,
          isRedirect: responseData.isRedirect,
          request: Request(
            responseData.method.toString().substring(7),
            Uri.parse(responseData.url),
          ),
        );

        return resultResponse as T;
      }
      return response;
    } finally {
      client.close();
    }
  }
}
