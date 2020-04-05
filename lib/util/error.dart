class ErrorMessage {
  // Error type
  ErrorType type;

  // Error message
  String error;

  // Error code icon from font awesome
  int icon;

  // Create network connection
  ErrorMessage.network() {
    icon = 0xf1eb;
    type = ErrorType.NETWORK_ERROR;
    error = 'Please check your network connection';
  }

  // Create custom error message
  ErrorMessage.custom(String e, {int code}) {
    // Use custom sad face as error icon
    if (code == null) {
      code = 0xf57a;
    }

    icon = code;
    type = ErrorType.DEFAULT_ERROR;
    error = e;
  }
}

enum ErrorType {
  NETWORK_ERROR,
  DEFAULT_ERROR,
}
