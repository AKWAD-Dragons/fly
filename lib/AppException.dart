class AppException implements Exception {
  String name;
  bool show;
  String beautifulMsg;
  int code;
  String uglyMsg;

  AppException(this.show,
      {this.name, this.code, this.beautifulMsg, this.uglyMsg});
}
