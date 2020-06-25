library fly;

import 'dart:async';

import 'dart:convert';

import 'dart:core';

import 'package:fly/NetworkProvider/APIManager.dart';

import 'package:http/http.dart';
import 'package:http_middleware/http_methods.dart';

typedef ErrorParsingException = Exception Function(Response response);
typedef SetParsingStartNode = dynamic Function(dynamic json);

class Fly {
  Fly() {
    _apiManager = APIManager();
  }

  APIManager _apiManager;
  FlyConfig _defaultConfigs;


  void setDefaultConfigs(FlyConfig defaultConfigs){
    _defaultConfigs = defaultConfigs;
  }

  Future request({
    String apiUrl,
    dynamic query,
    Parser parser,
    Method requestMethod,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) async {
    assert(_defaultConfigs?.apiUrl != null || apiUrl != null,
    "Add apiUrl in default configs or parameter");
    assert(_defaultConfigs?.parser != null || parser != null,
    "Add parser in default configs or parameter");
    assert(_defaultConfigs?.requestMethod != null || requestMethod != null,
    "Add requestMethod in default configs or parameter");

    apiUrl = apiUrl ?? _defaultConfigs.apiUrl;
    parser = parser ?? _defaultConfigs.parser;
    requestMethod = requestMethod ?? _defaultConfigs.requestMethod;
    query = query ?? _defaultConfigs?.query ?? null;
    customErrorParsing =
        customErrorParsing ?? _defaultConfigs?.customErrorParsing ?? null;
    setParsingStartNode =
        setParsingStartNode ?? _defaultConfigs?.setParsingStartNode ?? null;

    Response response = await _apiManager.request(apiUrl,
        body: jsonEncode(query), requestMethod: requestMethod);

    if (response.statusCode < 200 || response.statusCode > 299) {
      if (customErrorParsing != null) {
        throw customErrorParsing(response);
      }

      throw _dynamicErrorHandler(response);
    }

    dynamic myParsingNode = json.decode(response.body);
    if (setParsingStartNode != null) {
      myParsingNode = setParsingStartNode(myParsingNode);
    }

    if (myParsingNode == null) {
      return null;
    }

    final result = parser.dynamicParse(myParsingNode);

    return result;
  }

  FlyNetworkException _dynamicErrorHandler(Response response) {
    dynamic errorObj = json.decode(response.body);
    return FlyNetworkException(_findStrErr(errorObj));
  }

  String _findStrErr(dynamic error) {
    if (error is String) return error;
    if (error is List) {
      return _findStrErr(error[0]);
    }
    if (error is Map) {
      if (error.containsKey("error")) {
        return _findStrErr(error["error"]);
      } else if (error.containsKey("errors")) {
        return _findStrErr(error["errors"]);
      } else if (error.containsKey("message")) {
        return _findStrErr(error["message"]);
      } else {
        return _findStrErr(error.values.toList());
      }
    }

    return error.toString();
  }
}

abstract class Parser<T> {
  T parse(dynamic data);

  dynamic dynamicParse(dynamic data) {
    if (data is Map) {
      return parse(data);
    }

    List<T> dataList = [];
    data = data.toList();
    data.forEach((singleData) {
      dataList.add(parse(singleData));
    });

    return dataList;
  }
}

class FlyConfig {
  String apiUrl;
  dynamic query;
  Parser parser;
  Method requestMethod = Method.POST;
  ErrorParsingException customErrorParsing;
  SetParsingStartNode setParsingStartNode;

  FlyConfig({
    this.apiUrl,
    this.query,
    this.parser,
    this.requestMethod = Method.POST,
    this.customErrorParsing,
    this.setParsingStartNode,
  });
}

abstract class FlyException implements Exception {
  String message;
}

class FlyNetworkException implements FlyException {
  String message = "FlyNetworkException";

  FlyNetworkException(this.message);
}

class FlyParsingException implements FlyException {
  String message = "FlyParsingException";

  FlyParsingException(this.message);
}
