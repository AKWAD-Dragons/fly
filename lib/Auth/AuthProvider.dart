/*
 An Authentication utitlity provider that handles:
 TODO::
  - Logining with Google
  - Logining with LinkedIn
  - Logining with Facebook
  - email and password logining
  - Handeling user Authentication state
    * caching and refreshing tokens
    * checking for an authenticated user
    * unauthing a user
*/

// import 'package:atlasone/Support/providers/Auth/AuthMethod.dart';
// import 'package:atlasone/Support/providers/Auth/User.dart';

import 'package:fly_networking/Auth/shared_prefrence_provider.dart';
import 'package:fly_networking/fly.dart';
import 'package:get_it/get_it.dart';


import 'AuthMethod.dart';
import 'GraphCall.dart';
import 'User.dart';
import 'callType.dart';

class CallTypes {
  static final CallType garphCall = GraphCall();
  // static final CallType customCall = ;
}

class AuthProvider {
  static AuthUser _user;
  static Type _authMethodType;
  String baseUrl;
  Fly fly = GetIt.instance<Fly>();

  AuthProvider() {}

  Future<bool> isUserLoged() async {
    // 1- Check if user already exists in cache
    List<dynamic> _cachedUser =
        await SharedPreferencesProvider.instance().getUser("User");
    if (_cachedUser == null ||
        _cachedUser.length == 0 ||
        _cachedUser[0] == null) {
      return false;
    }

    List userData;
    userData = _cachedUser;
    print("The user is $userData");

    // 2- Check if user session is not expired
    AuthUser aUser = AuthUser.cached(userData[0], userData[1], userData[2],
        userData[3], userData[4], userData[5], userData[6]);
    print("The expire is ${isExpired(aUser)}");

    if (isExpired(aUser)) {
      logout();
      return false;
    }

    _user = aUser;
    fly.addHeaders({"Authorization": "Bearer ${_user.token}"});
    return true;
  }

  bool isExpired(AuthUser user) {
    print(user.expire);
    DateTime expireDate = DateTime.parse(user.expire);
    DateTime todayDate = DateTime.now();
    print("The expire date is $expireDate");
    print("Today date is $todayDate");
    final difference = expireDate.difference(todayDate).inDays;
    print("The diffrence is $difference");
    if (difference <= 2 && difference > 0) {
      print("You have two days before expire");
      return false;
    } else if (difference <= 0) {
      print("Your token is expired");
      return true;
    } else {
      print("You are ok to go");
      return false;
    }
  }

  Future<void> saveUser(savedUser) async {
    final SharedPreferencesProvider sharedPrefs =
        SharedPreferencesProvider.instance();
    sharedPrefs.setUser(savedUser);
  }

  Future<void> deleteUser() async {
    final SharedPreferencesProvider sharedPrefs =
        SharedPreferencesProvider.instance();
    await sharedPrefs.deleteUser();
  }

  Future<AuthUser> signUpWith({
    AuthMethod method,
    CallType callType,
  }) async {
    _user = await method.auth();

    // add the auth method type later use
    _authMethodType = method.runtimeType;

    // if (method.serviceName == 'email') return this._user;
    // send it to the api
    if (callType != null) {
      _user = await callType.call(_user);
    }

    // cache the jwt token
    return _user;
  }

  Future<AuthUser> loginWith({
    AuthMethod method,
    CallType callType,
  }) async {
    if (_user != null && _authMethodType == method.runtimeType) {
      return _user;
    }

    _user = await method.auth();

    // add the auth method type later use
    _authMethodType = method.runtimeType;

    // if (method.serviceName == 'email') return this._user;
    // send it to the api
    if (callType != null && _user != null) {
      _user = await callType.call(_user);
    }

    // cache the jwt token
    return _user;
  }

  Future<void> logout() {
    _user = null;
    deleteUser();
  }

  AuthUser get user => _user;

  setToken(String token) {
    _user.token = token;
  }
}
