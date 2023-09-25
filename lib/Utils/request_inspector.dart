import 'dart:convert';

import 'package:graphql_parser2/graphql_parser2.dart';
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
      methodType = "Query";
      requestBody['query'] = formatGraphQLQuery(requestBody['query']);
    } else if (requestBody.containsKey('mutation')) {
      methodType = "Mutation";
      requestBody['mutation'] = formatGraphQLQuery(requestBody['mutation']);
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

  String? formatGraphQLQuery(String requestBody) {
    var tokens = scan(requestBody);
    var parser = Parser(tokens);
    if (parser.errors.isNotEmpty) {
      return requestBody;
    }
    var doc = parser.parseDocument();
    doc.span?.text.replaceAll("}", "\n}\n");
    doc.span?.text.replaceAll("{", "\n{\n");
    return doc.span?.text;
  }
}
