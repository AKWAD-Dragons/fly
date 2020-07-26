import 'User.dart';

abstract class CallType {
  Future<AuthUser> call(AuthUser authuser);
}
