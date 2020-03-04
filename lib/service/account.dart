import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class AccountService extends Service {
  AccountService() : super();

  /// Sign in by using loginId and password
  /// Login id is e-mail address or username
  Future<SignInResponse> signIn(String loginId, String password) {
    final path = '/account/login';
    final body = {'login_id': loginId, 'password': password};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SignInResponse.bind(status: false, message: m);
      }

      return SignInResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SignInResponse.empty();
      return Service.handleError<SignInResponse>(e, s, r);
    };

    return Http.doPost(path, body: body).then(c).catchError(e);
  }
}

class SignInResponse extends BasicResponse {
  String auth;

  /// Create empty object
  SignInResponse.empty() : super.empty();

  /// Create only status and message
  SignInResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  SignInResponse.fromJson(String input) {
    final json = super.jsonToMap(input);

    auth = json['auth'] ?? null;
  }
}
