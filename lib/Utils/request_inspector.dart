import 'dart:convert';

import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:requests_inspector/requests_inspector.dart';

class RequestInspector implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    InspectorController().addNewRequest(
      RequestDetails(
        requestName: data.request?.body,
        requestMethod: RequestMethod.POST,
        requestBody:  jsonDecode(data.request?.body),
        url: data.request?.url ?? "",
        queryParameters: "",
        statusCode: data.statusCode,
        responseBody: data.body,
      ),
    );
    return data;
  }
}