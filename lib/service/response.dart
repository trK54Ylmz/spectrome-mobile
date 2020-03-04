import 'dart:convert';

abstract class JsonResponse {
  /// Map json string to dart class
  Map<String, dynamic> jsonToMap(String text) {
    return json.decode(text);
  }
}

class BasicResponse extends JsonResponse {
  bool status;

  String message;

  bool expired;

  bool isNetErr;

  /// Bind with custom parameters
  BasicResponse.bind({bool status, String message, bool isNetErr}) {
    this.status = status;
    this.message = message;
    this.isNetErr = isNetErr;
  }

  /// Convert http response body as json
  BasicResponse.fromJson(String input) {
    final json = jsonToMap(input);

    status = json['status'];
    expired = json['expired'] ?? null;
    message = json['message'] ?? null;
  }
}
