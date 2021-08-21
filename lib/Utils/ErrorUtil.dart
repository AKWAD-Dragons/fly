class ErrorUtil {
  static String? getMessageFromCode(int code) {
    switch (code) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized Request';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 408:
        return 'Internal Server Error';
      case 409:
        return 'Connection Request Timeout';
      case 500:
        return 'Error due to a conflict';
      case 503:
        return 'Service Unavailable';
    }
    return 'Unknown Error';
  }
}
