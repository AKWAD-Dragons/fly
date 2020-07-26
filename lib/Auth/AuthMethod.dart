import 'GoogleAuthMethod.dart';
import 'User.dart';

class MethodsType {
  static final AuthMethod googleMethod = GoogleAuthMethod();
  // static final AuthMethod faceBookMethod =
}

abstract class AuthMethod {
  String serviceName; // ex. google, facebook, github

  Future<AuthUser> auth();
}
