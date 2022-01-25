library fly_networking;

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:fly_networking/NetworkProvider/APIManager.dart';
import 'package:fly_networking/NetworkProvider/APIManager_Web.dart';
import 'package:fly_networking/Utils/ErrorUtil.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'AppException.dart';
import 'GraphQB/graph_qb.dart';

class Fly<T> {
  Fly(this._apiURL);

  late APIManager _apiManager = APIManager();
  late WebAPIManager _webAPIManager = WebAPIManager();
  String _apiURL;

  // Map<String, Parser> parserMap = {};
  Map<String, String> defaultParams = {};

  Future<Map<String, dynamic>?> query(
    List<Node> querys, {
    Map<String, dynamic>? qParams,
    Map<String, dynamic>? parsers,
    String? apiURL,
    Map<String, String>? parameters,
  }) async =>
      await graphMethod(
        methodName: 'query',
        mainQueryCols: querys,
        qParams: qParams,
        parsers: parsers,
        apiURL: apiURL,
        parameters: parameters,
      );

  Future<Map<String, dynamic>?> mutation(
    List<Node> mutations, {
    Map<String, dynamic>? qParams,
    Map<String, dynamic>? parsers,
    String? apiURL,
    Map<String, String>? parameters,
  }) async =>
      await graphMethod(
        methodName: 'mutation',
        mainQueryCols: mutations,
        qParams: qParams,
        parsers: parsers,
        apiURL: apiURL,
        parameters: parameters,
      );

  Future<Map<String, dynamic>?> graphMethod({
    required String methodName,
    List<Node>? mainQueryCols,
    Map<String, dynamic>? qParams,
    Map<String, dynamic>? parsers,
    String? apiURL,
    Map<String, String>? parameters,
  }) async {
    Node mainQuery = Node(name: methodName, cols: mainQueryCols);

    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": GraphQB(mainQuery).getQueryFor(args: qParams)
    };
    Map<String, dynamic>? results = await this.requestWithoutParse(
        query: queryMap, apiUrl: apiURL, parameters: parameters);

    if (parsers == null || parsers.length == 0) return results;

    return _parseResults(results, parsers);
  }

  Future<T> request({
    String? apiUrl,
    required dynamic query,
    Map<String, String>? parameters,
    Parser<T>? parser,
  }) async {
    Map<String, dynamic>? results = await this.requestWithoutParse(
        query: query, apiUrl: apiUrl, parameters: parameters);

    if (parser == null) return results as T;

    return parser.parse(results);
  }

  Future<Map<String, dynamic>?> requestWithoutParse(
      {String? apiUrl,
      required dynamic query,
      Map<String, String>? parameters}) async {
    if (apiUrl == null) apiUrl = _apiURL;
    if (parameters == null) parameters = defaultParams;

    Response? response;

    if (kIsWeb) {
      response = await _webAPIManager.post(
        apiUrl,
        body: jsonEncode(query),
      );
    } else {
      response = await _apiManager.post(
        apiUrl,
        body: jsonEncode(query),
      );
    }
    print(response?.body);

    if (response == null)
      throw AppException(true,
          beautifulMsg: 'Error occured',
          title: "Server Error",
          code: 0,
          uglyMsg: "No response from server");

    if (response.statusCode > 400) {
      throw AppException(true,
          beautifulMsg: ErrorUtil.getMessageFromCode(response.statusCode),
          code: response.statusCode,
          title: 'HTTP ERROR');
    }

    Map<String, dynamic> myData = json.decode(response.body);
    // has error
    if (myData.containsKey("errors")) {
      String? error = myData['errors'][0]['message'];
      int? code = myData['errors'][0]['extensions']['code'];
      String? title = myData['errors'][0]['extensions']['title'];

      throw AppException(
        true,
        beautifulMsg: error ?? 'Error occured',
        title: title ?? "Server Error",
        code: code ?? 200,
        uglyMsg: myData.toString(),
      );
    }

    return myData['data'];
  }

  Map<String, dynamic>? _parseResults(
      Map<String, dynamic>? results, Map<String, dynamic>? parsers) {
    if (parsers == null) return null;
    try {
      return results?.map((key, value) {
        if (!parsers.containsKey(key)) return MapEntry(key, value);

        if (value is List) {
          return MapEntry(key, parsers[key].dynamicParse(value));
        } else {
          return MapEntry(key, parsers[key].parse(value));
        }
      });
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  void addHeaders(Map<String, String> headers) {
    _apiManager.setHeaders(headers);
    _webAPIManager.setHeaders(headers);
  }
}

abstract class Parser<T> {
  List<String>? querys;

  T parse(dynamic data);

  dynamic dynamicParse(dynamic data) {
    if (!(data is List)) {
      return parse(data);
    }

    List<T> dataList = [];
    data.forEach((singleData) {
      dataList.add(parse(singleData));
    });

    return dataList;
  }
}

class Pasring<T> {
  T parsing(Parser<T> data) {
    return data.parse(data);
  }
}
