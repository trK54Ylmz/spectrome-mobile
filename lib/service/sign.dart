import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class SignService extends Service {
  final String auth;

  SignService(this.auth) : super();

  /// Sign in by using loginId and password
  /// Login id is e-mail address or username
  Future<BasicResponse> signIn(String loginId, String password) {
    final path = '/account/login';
    final headers = {Http.CONTENT_HEADER: auth};
    final body = {'login_id': loginId, 'password': password};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return BasicResponse.bind(status: false, message: m);
      }

      return BasicResponse.fromJson(r.body);
    };

    return Http.doPost(path, body: body, headers: headers).then(c).catchError(Http.catchError);
  }
}
