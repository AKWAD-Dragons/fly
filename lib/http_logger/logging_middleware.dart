import 'package:fly_networking/http_middleware/middleware_contract.dart';
import 'package:fly_networking/http_middleware/models/request_data.dart';
import 'package:fly_networking/http_middleware/models/response_data.dart';

import 'log_level.dart';
import 'logger.dart';

class HttpLogger implements MiddlewareContract {
  LogLevel logLevel;
  late Logger logger;

  HttpLogger({
    this.logLevel: LogLevel.BODY,
  }) {
    logger = Logger(logLevel: logLevel);
  }

  @override
  void interceptRequest(RequestData data) {
    logger.logRequest(data);
  }

  @override
  void interceptResponse(ResponseData data) {
    logger.logResponse(data);
  }
}
