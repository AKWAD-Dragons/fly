import 'package:fly_networking/fly.dart';
import 'package:fly_networking/GraphQB/graph_qb.dart';

import 'AuthMethod.dart';
import 'User.dart';

class EmailSignupMethod implements AuthMethod {
  @override
  String serviceName = 'email';
  String _email;
  String _password;
  String _confirmPassword;

  Node signupMutation;

  String signupLink;
  Fly fly;

  EmailSignupMethod(this._email, this._password, this._confirmPassword) {
    // create the query
    fly = Fly(this.signupLink);
    signupMutation = Node(
      name: 'create_auth_user',
      args: {
        "type": "email",
        "credentials": {
          "email": this._email,
          "password": this._password,
          "confirmPassword": this._confirmPassword
        },
      },
    );
  }

  void setSignupLink(String link) {
    signupLink = link + '/graphql';
  }

  @override
  Future<AuthUser> auth() async {
    final result = await fly.mutation([this.signupMutation]);
    return AuthUser();
  }
}
