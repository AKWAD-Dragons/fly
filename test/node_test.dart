import 'package:flutter_test/flutter_test.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';

void main() {
  test('Node string format validator', () async {
    final Node fullNode = Node(
      alias: 'alias',
      name: 'name',
      args: {'key 1': 'value 1', 'key2': 'value2'},
      cols: ['id', 'name'],
    );
    final Node nodeWithoutArgs = Node(
      alias: 'alias',
      name: 'name',
      cols: ['id'],
    );
    final Node nodeWithoutCols = Node(
      alias: 'alias',
      name: 'name',
      args: {'myKey': 'myValue'},
    );
    final Node nodeWithNameOnly = Node(
      name: 'name',
    );
    final Node nodeWithoutAlias = Node(
      name: 'name',
      args: {'myKey': 'myValue'},
      cols: ['id'],
    );
    final Node emptyNode = Node(name: 'name');

    RegExp validNodeRegex = RegExp(r'^'
        '([A-Za-z]+:)*' //  Alias
        '[A-Za-z]+' //      Name
        '(\(.*\))*' //      Arguments
        '(\{^.*\})*' //     Columns
        );

    expect(validNodeRegex.hasMatch(fullNode.toString()), true);
    expect(validNodeRegex.hasMatch(nodeWithoutArgs.toString()), true);
    expect(validNodeRegex.hasMatch(nodeWithoutCols.toString()), true);
    expect(validNodeRegex.hasMatch(nodeWithNameOnly.toString()), true);
    expect(validNodeRegex.hasMatch(nodeWithoutAlias.toString()), true);
    expect(validNodeRegex.hasMatch(emptyNode.toString()), true);
  });

  test('Node types', () {
    String myString = '''string value\nbackslash
    new-line value''';
    int myInt = 5;
    double myDouble = 3.8;
    String myEnum = "_ENUM";

    Node node = Node(
      name: "updateCollector",
      args: {
        "string": myString,
        "int": myInt,
        "double": myDouble,
        "enum": myEnum,
      },
      cols: ["id"],
    );

    print(node);
  });
}
