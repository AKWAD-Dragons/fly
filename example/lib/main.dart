import 'package:flutter/material.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';
import 'package:fly_networking/fly.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Fly _fly = Fly("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("example"),
      ),
      body: Center(
        child: RaisedButton(
          child: Text("TEST"),
          onPressed: () async => await _sendRequest(),
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    String myString = '''string value\nbackslash
    new-line value''';
    int myInt = 5;
    double myDouble = 3.8;
    String myEnum = "_ENUM";

    Node node = Node(
      name: "updateCollector",
      args: {
        "id": "564",
        "input": {
          "requests": {
            "update": {
              "id": "54",
              "collected_quantityss": myDouble,
              "collected_quantity": '_$myDouble',
              "selectedGifts": {
                "delete": "sd",
              }
            }
          }
        }
      },
      cols: ["id"],
    );

    await _fly.mutation([node]);
  }
}
