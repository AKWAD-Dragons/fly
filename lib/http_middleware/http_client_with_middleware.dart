import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'middleware_contract.dart';

///Class to be used by the user to set up a new `http.Client` with middleware supported.
///call the `build()` constructor passing in the list of middlewares.
///Example:
///```dart
/// HttpClientWithMiddleware httpClient = HttpClientWithMiddleware.build(middlewares: [
///     Logger(),
/// ]);
///```
///
///Then call the functions you want to, on the created `http` object.
///```dart
/// httpClient.get(...);
/// httpClient.post(...);
/// httpClient.put(...);
/// httpClient.delete(...);
/// httpClient.head(...);
/// httpClient.patch(...);
/// httpClient.read(...);
/// httpClient.readBytes(...);
/// httpClient.send(...);
/// httpClient.close();
///```
///Don't forget to close the client once you are done, as a client keeps
///the connection alive with the server.
class HttpClientWithMiddleware extends http.BaseClient {
  List<MiddlewareContract?> middlewares;
  final IOClient _client = IOClient();

  HttpClientWithMiddleware._internal({required this.middlewares});

  factory HttpClientWithMiddleware.build(
      {required List<MiddlewareContract?> middlewares}) {
    //Remove any value that is null.
    middlewares.removeWhere((middleware) => middleware == null);
    return HttpClientWithMiddleware._internal(middlewares: middlewares);
  }

  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  void close() {
    _client.close();
  }
}
