import 'package:flutter/foundation.dart';

class GraphQB {
  //Singleton starts

  GraphQB(this.query) {
    stringQuery = query.toString();
  }

  //Singleton ends

  // Map<String, String> _namedQueries = {};
  final Node query;
  late String stringQuery;
  // void addNamedQuery(String queryName, String query) {
  //   _namedQueries[queryName] = query;
  //   print(query);
  // }

  String getQueryFor({Map<String, dynamic>? args}) {
    if (args == null) return this.stringQuery;
    args.forEach((String key, dynamic val) {
      this.stringQuery = stringQuery.replaceAll("##$key##", val);
    });
    return this.stringQuery;
  }
}

class Node {
  final String name;
  final Map<String, dynamic>? args;
  final List<dynamic>? cols;
  Node({required this.name, this.args, this.cols});

  void appendArg(String key, dynamic val) {
    if (args != null) args![key] = val;
  }

  @override
  String toString() {
    String nodeStr = "";
    nodeStr = name;
    if (args != null && args!.isNotEmpty) {
      nodeStr += "(";

      args!.forEach((String key, dynamic val) {
        nodeStr += "$key: ${this.parseArgs(val)} ,";
      });

      nodeStr = nodeStr.substring(0, nodeStr.length - 1);

      nodeStr += ")";
    }
    if (cols != null && cols!.isNotEmpty) {
      nodeStr += "{\n";
      cols!.forEach((dynamic col) {
        nodeStr += col.toString() + "\n";
      });
      nodeStr += "}";
    }
    return nodeStr;
  }

  String parseArgs(dynamic arg) {
    String parsed = "";
    if (arg is Map) {
      parsed += "{";
      arg.forEach((key, value) {
        parsed += "$key:${this.parseArgs(value)},";
      });
      if (arg.length != 0) {
        parsed = parsed.substring(0, parsed.length - 1);
      }
      parsed += "}";
    } else if (arg is List) {
      parsed += "[";
      arg.forEach((value) {
        parsed += "${this.parseArgs(value)},";
      });
      if (arg.length != 0) {
        parsed = parsed.substring(0, parsed.length - 1);
      }
      parsed += "]";
    } else if (arg is int) {
      parsed = "$arg";
    } else if (arg is double) {
      parsed = "$arg";
    } else if (arg is bool) {
      parsed = "$arg";
    } else if (arg is String && arg.substring(0, 1) == "_") {
      parsed = "${arg.substring(1, arg.length)}";
    } else if (arg is String) {
      parsed = "\"$arg\"";
    } else if (arg == null) {
      parsed = "null";
    }
    return parsed;
  }
}
