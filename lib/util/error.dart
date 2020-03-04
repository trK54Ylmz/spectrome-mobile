class ErrorMessage {
  ErrorType type;

  String error;

  // Create network connection
  ErrorMessage.network() {
    type = ErrorType.NETWORK_ERROR;
    error = 'Please check your network connection';
  }

  // Create custom error message
  ErrorMessage.custom(String e) {
    type = ErrorType.DEFAULT_ERROR;
    error = e;
  }
}

enum ErrorType {
  NETWORK_ERROR,
  DEFAULT_ERROR,
}
