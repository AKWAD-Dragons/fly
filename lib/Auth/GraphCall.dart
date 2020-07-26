import 'package:fly_networking/Auth/User.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';
import 'package:fly_networking/fly.dart';

import 'callType.dart';

class GraphCall implements CallType {
  String signupLink;
  Fly fly;

  GraphQB _authGraph = GraphQB(Node(name: "mutation", cols: [
    Node(name: "create_auth_user", args: {
      "type": "##type##",
      "credentials": {
        'token': "##token##",
      },
    }, cols: [
      'jwtToken',
      'expire'
    ])
  ]));

  GraphCall() {
    this.fly = Fly<AuthUser>('https://$signupLink');
  }

  void setSignupLink(String link) {
    signupLink = link + '/graphql';
  }

  @override
  Future<AuthUser> call(AuthUser authuser) async {
    String query = _authGraph.getQueryFor(args: {
      "##type##": "${authuser.credintials}",
      "##token##": "${authuser.token}"
    });

    Map<String, dynamic> newQuery = {
      "operationName": null,
      "variables": {},
      "query": "$query"
    };
    // print(newQuery.toString());
    // final AuthUser user =
    return await fly.request(query: newQuery, parser: AuthUser());

    //  print("TOKEN -----${user.token}");
  }
}
