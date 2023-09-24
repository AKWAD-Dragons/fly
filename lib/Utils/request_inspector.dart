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
    final requestBody = jsonDecode(data.request?.body) as Map<String, dynamic>;
    String methodType = "";
    if (requestBody.containsKey('query')) {
      print(requestBody['query'] );
      requestBody['query'] = jsonDecode(requestBody['query'].toString());
      methodType = "Query";
    } else if (requestBody.containsKey('mutation')) {
      print(requestBody['mutation'] );
      requestBody['mutation'] = jsonDecode(requestBody['mutation'].toString());
      methodType = "Mutation";
    }
    InspectorController().addNewRequest(
      RequestDetails(
        requestName: methodType,
        requestMethod: RequestMethod.POST,
        requestBody: requestBody,
        url: data.request?.url ?? "",
        queryParameters: "",
        statusCode: data.statusCode,
        responseBody: jsonDecode(data.body ?? ""),
      ),
    );
    return data;
  }
}
