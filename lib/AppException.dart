class AppException implements Exception {
  String title;
  bool show;
  int code;
  String? beautifulMsg;
  String? uglyMsg;

  AppException(
    this.show, {
    required this.title,
    required this.code,
    this.beautifulMsg,
    this.uglyMsg,
  });
}
