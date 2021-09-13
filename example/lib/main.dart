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
    double quantity = 8;
    Node deleteSelectedGifts = Node(name: "updateCollector", args: {
      "double": quantity,
      "double2": '_$quantity',
    }, cols: [
      "id",
    ]);

    await _fly.mutation([deleteSelectedGifts]);
  }
}
