library fly_networking;
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:fly_networking/NetworkProvider/APIManager.dart';
import 'AppException.dart';
import 'GraphQB/graph_qb.dart';
import 'package:flutter/cupertino.dart';
import 'package:fly_networking/dio/lib/dio.dart';
import 'dart:io';

class Fly<T> {
  Fly(this._apiURL,
      {Duration timeout = const Duration(seconds: 3),
      Function onTimeOut,
      Map headers}) {
    _apiManager = APIManager();
    _apiManager.setTimeOut(timeout, onTimeOut: onTimeOut ?? () {});
  }

  APIManager _apiManager;
  String _apiURL;
  String _encodedBody;
  // Map<String, Parser> parserMap = {};
  String link;
  Map<String, String> defaultParams = {};

  void setEncodedBodyFromMap({@required Map<String, dynamic> map}) {
    _encodedBody = jsonEncode(map);
  }

  Map<String, String> map = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptHeader: "application/json",
  };

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
    if (parsers != null) {
      try {
        return results.map((key, value) {
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
    return results;
  }

  void addHeaders(Map<String, String> headers) {
    _apiManager.setHeaders(headers);
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
    return results.map((key, value) {
      if (!parsers.containsKey(key)) return MapEntry(key, value);
      return MapEntry(key, parsers[key].parse(value));
    });
  }

  Future<Response> post(String apiPath, {FormData data}) async {
    try {
      Uri uri = Uri.parse(link + apiPath);
      if (uri.scheme == "https") {
        uri = Uri.https(uri.authority, uri.path);
      } else {
        uri = Uri.http(uri.authority, uri.path);
      }
      print(uri);
      data != null ? print(data.fields) : print(_encodedBody);
      final response = await Dio().post(uri.toString(),
          data: data != null ? data : _encodedBody,
          options: Options(headers: map));
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.response.statusCode);
      }
      return null;
    }
  }

  Future<Response> get(String apiPath, {Map<String, String> parameter}) async {
    try {
      Uri uri = Uri.parse(link + apiPath);
      if (uri.scheme == "https") {
        uri = Uri.https(uri.authority, uri.path, parameter);
      } else {
        uri = Uri.http(uri.authority, uri.path, parameter);
      }
      final response =
          await Dio().get(uri.toString(), options: Options(headers: map));
      print(response);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.response.statusCode);
      }
      return null;
    }
  }

  Future<Response> put(String apiPath) async {
    try {
      Uri uri = Uri.parse(link + apiPath);
      if (uri.scheme == "https") {
        uri = Uri.https(uri.authority, uri.path);
      } else {
        uri = Uri.http(uri.authority, uri.path);
      }
      final response = await Dio().put(uri.toString(),
          data: _encodedBody, options: Options(headers: map));
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.response.statusCode);
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> requestWithoutParse(
      {String apiUrl, dynamic query, Map<String, String> parameters}) async {
    if (_apiURL == null && apiUrl == null) {
      throw ("apiUrl is not set! call init or add apiUrl in request");
    }
    if (apiUrl == null) {
      apiUrl = _apiURL;
    }
    if (parameters == null) {
      parameters = defaultParams;
    }

    Response response = await _apiManager.post(
      apiUrl,
      body: jsonEncode(query),
    );
    dynamic myData = response.data;

    // has error
    if (myData.containsKey("errors")) {
      String error = myData['errors'][0]['message'];
      String trace = myData['errors'][0]['trace'].toString();
      int code = myData['errors'][0]['extensions']['code'];
      throw AppException(true,
          beautifulMsg: error ?? 'Error occured',
          name: "Server Error",
          code: code,
          uglyMsg: trace);
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

    Response response = await _apiManager.post(
      apiUrl,
      body: jsonEncode(query),
    );
    dynamic myData = response.data;

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
