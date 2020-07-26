import 'dart:convert';

import 'package:fly_networking/Auth/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  ///// Singleton
  static SharedPreferencesProvider _spProvider;

  SharedPreferences prefs;
  String USER = "User";
  String BUILDNUMBER = "build";
  String LOCALE = "LOCALE";

  static SharedPreferencesProvider instance() {
    if (_spProvider == null) {
      _spProvider = SharedPreferencesProvider._();
    }
    return _spProvider;
  }

  SharedPreferencesProvider._();

  AuthUser _user;
  AuthUser get currentUser => this._user;

  void setUser(AuthUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        USER, json.encode([user.token, user.id, user.expire, user.credintials, user.role,user.email,"false"]).toString());
  }

  Future deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(USER);
  }

  Future<List<dynamic>> getUser(String USER) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString(USER) == null){
      return null;
    }
    List<dynamic> user = json.decode(prefs.getString(USER));
    return user;
  }

  void setBuildNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(BUILDNUMBER, number);
  }

  Future<String> getBuildNumber(String BUILD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(BUILD);
  }

  Future<String> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LOCALE);
  }

  Future<void> setLocale(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(LOCALE,locale);
  }
}
