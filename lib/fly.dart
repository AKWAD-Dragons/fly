library fly;

import 'dart:async';

import 'dart:convert';

import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:fly/NetworkProvider/APIManager.dart';
import 'package:graphqb/graphqb.dart';
import 'package:http/http.dart' show Response;
import 'package:http_middleware/http_methods.dart';

typedef ErrorParsingException = Exception Function(Response response);
typedef SetParsingStartNode = dynamic Function(dynamic json);

class Fly {
  Fly() {
    _apiManager = APIManager();
  }

  APIManager _apiManager;
  FlyConfig _defaultConfigs;

  void setDefaultConfigs(FlyConfig defaultConfigs) {
    _defaultConfigs = defaultConfigs;
  }

  Future post({
    String apiUrl,
    @required String path,
    dynamic body,
    Parser parser,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    assert(_defaultConfigs?.parser != null || parser != null,
        "Add parser in default configs or parameter");
    return _request(
        apiUrl: apiUrl,
        path: path,
        parser: parser,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.POST,
        body: body,
        customErrorParsing: customErrorParsing);
  }

  Future put({
    String apiUrl,
    @required String path,
    dynamic body,
    Parser parser,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    assert(_defaultConfigs?.parser != null || parser != null,
        "Add parser in default configs or parameter");
    return _request(
        apiUrl: apiUrl,
        path: path,
        parser: parser,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.PUT,
        body: body,
        customErrorParsing: customErrorParsing);
  }

  Future patch({
    String apiUrl,
    @required String path,
    dynamic body,
    Parser parser,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    assert(_defaultConfigs?.parser != null || parser != null,
        "Add parser in default configs or parameter");
    return _request(
        apiUrl: apiUrl,
        path: path,
        parser: parser,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.PATCH,
        body: body,
        customErrorParsing: customErrorParsing);
  }

  Future get({
    String apiUrl,
    @required String path,
    Parser parser,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    assert(_defaultConfigs?.parser != null || parser != null,
        "Add parser in default configs or parameter");
    return _request(
        apiUrl: apiUrl,
        path: path,
        parser: parser,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.GET,
        customErrorParsing: customErrorParsing);
  }

  Future delete({
    String apiUrl,
    @required String path,
    Parser parser,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    assert(_defaultConfigs?.parser != null || parser != null,
        "Add parser in default configs or parameter");
    return _request(
        apiUrl: apiUrl,
        path: path,
        parser: parser,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.DELETE,
        customErrorParsing: customErrorParsing);
  }

  Future head({
    String apiUrl,
    @required String path,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) {
    return _request(
        apiUrl: apiUrl,
        path: path,
        setParsingStartNode: setParsingStartNode,
        requestMethod: Method.HEAD,
        customErrorParsing: customErrorParsing);
  }

  Future mutation(
    Node mutation, {
    String apiUrl,
    String path,
    Parser parser,
  }) async {
    Node mainQuery = Node(name: 'mutation', cols: [mutation]);

    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": mainQuery.toString(),
    };
    return await _request(
      apiUrl: apiUrl,
      body: queryMap,
    );
  }

  Future query(
    Node query, {
    String apiUrl,
    String path,
    Parser parser,
  }) async {
    Node mainQuery = Node(name: 'query', cols: [query]);

    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": mainQuery.toString(),
    };
    return await _request(
      apiUrl: apiUrl,
      path: path,
      parser: parser,
      body: queryMap,
    );
  }

  Future _request({
    String apiUrl,
    String path,
    dynamic body,
    Parser parser,
    Method requestMethod,
    ErrorParsingException customErrorParsing,
    SetParsingStartNode setParsingStartNode,
  }) async {
    assert(_defaultConfigs?.apiUrl != null || apiUrl != null,
        "Add apiUrl in default configs or parameter");
    assert(path != null && path.startsWith('/'),
        "path must not be null and must start with '/'");

    apiUrl = apiUrl ?? _defaultConfigs.apiUrl;
    parser = parser ?? _defaultConfigs.parser;
    body = body ?? _defaultConfigs?.body ?? null;
    customErrorParsing =
        customErrorParsing ?? _defaultConfigs?.customErrorParsing ?? null;
    setParsingStartNode =
        setParsingStartNode ?? _defaultConfigs?.setParsingStartNode ?? null;

    Response response = await _apiManager.request(apiUrl,
        body: jsonEncode(body), requestMethod: requestMethod);

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

  FlyAPIException _dynamicErrorHandler(Response response) {
    dynamic errorObj = json.decode(response.body);
    return FlyAPIException(_findStrErr(errorObj));
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
  dynamic body;
  Parser parser;
  ErrorParsingException customErrorParsing;
  SetParsingStartNode setParsingStartNode;

  FlyConfig({
    this.apiUrl,
    this.body,
    this.parser,
    this.customErrorParsing,
    this.setParsingStartNode,
  });
}

abstract class FlyException implements Exception {
  String message;
}

//TODO:: Add NetworkExceptions

class FlyAPIException implements FlyException {
  String message = "FlyAPIException";

  FlyAPIException(this.message);
}

class FlyParsingException implements FlyException {
  String message = "FlyParsingException";

  FlyParsingException(this.message);
}
