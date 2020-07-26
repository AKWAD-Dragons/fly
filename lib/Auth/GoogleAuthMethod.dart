import 'AppException.dart';
import 'AuthMethod.dart';
import 'User.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthMethod implements AuthMethod {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly'
    ],
  );

  @override
  String serviceName;

  AuthUser user;

  GoogleAuthMethod() {
    this.serviceName = 'google';
  }

  @override
  Future<AuthUser> auth() async {
    if (this.user != null) {
      return this.user;
    }

    GoogleSignInAuthentication auth;
    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();
      auth = await account.authentication;
    } catch (e, s) {
      new AppException(true,
          name: "googleAuthFailed",
          code: 500,
          beautifulMsg: "Google Signing didn't work",
          uglyMsg: s.toString());
    }
    this.user = AuthUser(credintials: {
      "accessToken": auth.accessToken,
      "idToken": auth.idToken
    });
    return this.user;
  }
}
