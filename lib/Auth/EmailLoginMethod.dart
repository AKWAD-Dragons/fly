import 'dart:convert';

import 'package:fly_networking/Auth/shared_prefrence_provider.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';
import 'package:fly_networking/fly.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'AuthMethod.dart';
import 'User.dart';

class EmailLoginMethod implements AuthMethod {
  @override
  String serviceName = 'email';
  String _email;
  String _password;

  Node signupMutation;

  String signupLink;
  Fly fly;

  EmailLoginMethod(this._email, this._password) {
    // create the query
    fly = Fly(this.signupLink);
    signupMutation = Node(name: "mutation", cols: [
      Node(name: 'auth_user', args: {
        "type": "email",
        "credentials": {"email": this._email, "password": this._password},
      }, cols: [
        'jwtToken',
        'expire',
        'id',
        'role'
      ])
    ]);
  }

  void setSignupLink(String link) {
    signupLink = link + '/graphql';
  }

  Future<void> saveUser(savedUser) async {
    final SharedPreferencesProvider sharedPrefs =
        SharedPreferencesProvider.instance();
    sharedPrefs.setUser(savedUser);
  }

  @override
  Future<AuthUser> auth() async {
    Map queryMap = {
      "operationName": null,
      "variables": {},
      "query": GraphQB(this.signupMutation).getQueryFor()
    };

     AuthUser user = await fly.request(query: queryMap, parser: AuthUser());
     saveUser(user);
     return user;
  }
}
