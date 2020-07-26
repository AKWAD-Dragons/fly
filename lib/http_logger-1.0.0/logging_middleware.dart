
import 'package:fly/http_logger-1.0.0/log_level.dart';
import 'package:fly/http_logger-1.0.0/logger.dart';
import 'package:fly/http_middleware-1.0.0/middleware_contract.dart';
import 'package:fly/http_middleware-1.0.0/models/request_data.dart';
import 'package:fly/http_middleware-1.0.0/models/response_data.dart';

class HttpLogger implements MiddlewareContract {
  LogLevel logLevel;
  Logger logger;

  HttpLogger({
    this.logLevel: LogLevel.BODY,
  }) {
    logger = Logger(logLevel: logLevel);
  }

  @override
  void interceptRequest({RequestData data}) {
    logger.logRequest(data: data);
  }

  @override
  void interceptResponse({ResponseData data}) {
    logger.logResponse(data: data);
  }
}
