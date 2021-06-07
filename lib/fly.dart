library fly_networking;

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:fly_networking/NetworkProvider/APIManager.dart';
import 'package:fly_networking/NetworkProvider/APIManager_Web.dart';
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

  Future<Map<String, dynamic>> query(
    List<Node> querys, {
    Map<String, dynamic> qParams,
    Map<String, dynamic> parsers,
    String apiURL,
    Map<String, String> parameters,
  }) async {
    Node mainQuery = Node(name: 'query', cols: querys);

    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": GraphQB(mainQuery).getQueryFor(args: qParams)
    };

    Map<String, dynamic> results = await this.requestWithoutParse(
        query: queryMap, apiUrl: apiURL, parameters: parameters);

    if (parsers != null) return _parseResults(results, parsers);

    return results;
  }

  Map<String, dynamic> _parseResults(
      Map<String, dynamic> results, Map<String, dynamic> parsers) {
    try {
      return results.map((key, value) {
        if (!parsers.containsKey(key)) return MapEntry(key, value);

        if (value is List) {
          return MapEntry(key, parsers[key].dynamicParse(value));
        } else {
          print("INSIDE IS NOOOT " + key);
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

  Future<Map<String, dynamic>> mutation(
    List<Node> mutations, {
    Map<String, dynamic> qParams,
    Map<String, Parser<T>> parsers,
    String apiURL,
    Map<String, String> parameters,
  }) async {
    Node mainQuery = Node(name: 'mutation', cols: mutations);

    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": GraphQB(mainQuery).getQueryFor(args: qParams)
    };
    Map<String, dynamic> results = await this.requestWithoutParse(
        query: queryMap, apiUrl: apiURL, parameters: parameters);
    if (parsers == null || parsers.length == 0 || results == null)
      return results;

    return _parseResults(results, parsers);
  }

  Future<Map<String, dynamic>> requestWithoutParse(
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

    if (response == null)
      throw AppException(true,
          beautifulMsg: 'Error occured',
          name: "Server Error",
          code: 0,
          uglyMsg: "No response from server");

    Map<String, dynamic> myData = json.decode(response.body);
    // has error
    if (myData.containsKey("errors")) {
      String? error = myData['errors'][0]['message'];
      String? trace = myData['errors'][0]['trace'].toString();
      int code = myData['errors'][0]['extensions']['code'];
      throw AppException(
        true,
        beautifulMsg: error ?? 'Error occured',
        name: "Server Error",
        code: code,
        uglyMsg: trace,
      );
    }

    return myData['data'];
  }

  Future<T> request({
    String apiUrl,
    dynamic query,
    Map<String, String> parameters,
    Parser<T> parser,
  }) async {
    if (_apiURL == null && apiUrl == null) {
      throw ("apiUrl is not set! call init or add apiUrl in request");
    }
    if (apiUrl == null) {
      apiUrl = _apiURL;
    }
    if (parameters == null) {
      parameters = defaultParams;
    }

    Response response;
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

    Map<String, dynamic> myData = json.decode(response.body);

    // has error
    if (myData.containsKey("errors")) {
      String error = myData['errors'][0]['message'];
      String trace = myData['errors'][0]['trace'].toString();
      int code = myData['errors'][0]['extensions']['code'];

      throw AppException(true,
          beautifulMsg: error,
          name: "Server Error",
          code: code,
          uglyMsg: trace);
    }

    if (myData["data"] == null) {
      return null;
    }

    final result = parser.parse(myData['data']);

    return result;
  }
}

abstract class Parser<T> {
  List<String> querys;

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
