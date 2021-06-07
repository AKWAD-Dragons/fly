class AppException implements Exception {
  String name;
  bool show;
  int code;
  String? beautifulMsg;
  String? uglyMsg;

  AppException(
    this.show, {
    required this.name,
    required this.code,
    this.beautifulMsg,
    this.uglyMsg,
  });
}
