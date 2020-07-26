import 'dart:convert';

import 'package:fly_networking/fly.dart';


class AuthUser implements Parser<AuthUser> {
  String credintials;
  String expire;
  String token;
  String id;
  String role;
  String email;
  String first_logged;

  AuthUser({this.token, Map<String, String> credintials}) {
    this.credintials = jsonEncode(credintials);
  }

  AuthUser.forProfile(this.id,this.email,this.role,this.first_logged);

  AuthUser.cached(String token, String id, String expire, String credentials,
      String role, String email, String first_logged) {
    this.token = token;
    this.id = id;
    this.expire = expire;
    this.credintials = credentials;
    this.role = role;
    this.email = email;
    this.first_logged = first_logged;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json){
    return AuthUser.forProfile(
      json["id"],
      json["email"],
      json["role"],
      json["first_logged"]?"true":"false",
    );
  }

  Map<String, dynamic> toJson() => {
    'id':id,
    'email':email,
    'role':role,
    'first_logged':first_logged
  };

  @override
  dynamicParse(data) {
    // TODO: implement dynamicParse
    return null;
  }

  @override
  AuthUser parse(data) {
    Map parsingData = data;
    if (parsingData.containsKey('auth_user')) {
      this.expire = data['auth_user']['expire'];
      this.token = data['auth_user']['jwtToken'];
      this.id = data['auth_user']['id'];
      this.role = data['auth_user']['role'];
      this.email = data['auth_user']['email'];
      this.first_logged = data['auth_user']['first_logged'];
    } else if(parsingData.containsKey('jwtToken')) {
      this.expire = data['expire'];
      this.token = data['jwtToken'];
      this.id = data['id'];
      this.role = data['role'];
      this.email = data['email'];
      this.first_logged = data['first_logged'];
    } else {
      this.expire = data['create_auth_user']['expire'];
      this.token = data['create_auth_user']['jwtToken'];
      this.id = data['create_auth_user']['id'];
    }
    return this;
  }

  @override
  List<String> querys;
}
