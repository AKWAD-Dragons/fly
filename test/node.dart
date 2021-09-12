import 'package:flutter_test/flutter_test.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';

void main() {
  test('Node to string', () async {
    final Node nodeWithAlias = Node(
      alias: "alias",
      name: "name",
      args: {"myKey": "myValue"},
      cols: ["id"],
    );
    RegExp regex1 = RegExp(r"^[A-Za-z]*:[A-Za-z]*\(.*");
    final Node nodeWithoutAlias = Node(
      name: "name",
      args: {"myKey": "myValue"},
      cols: ["id"],
    );
    RegExp regex2 = RegExp(r"^[A-Za-z]*\(.*");

    expect(regex1.hasMatch(nodeWithAlias.toString()), true);
    expect(regex2.hasMatch(nodeWithoutAlias.toString()), true);
  });
}
