import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class AccountService extends Service {
  AccountService() : super();

  /// Sign in by using loginId and password
  /// Login id is e-mail address or username
  Future<SignInResponse> signIn(String loginId, String password) {
    final path = '/account/login';
    final body = {
      'login_id': loginId,
      'password': password,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SignInResponse.bind(status: false, message: m);
      }

      dev.log(r.body);

      return SignInResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SignInResponse.empty();
      return Service.handleError<SignInResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }

  /// Activate account by using activation code
  Future<ActivationResponse> activate(int code) {
    final path = '/account/activate';
    final params = {'code': code.toString()};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ActivationResponse.bind(status: false, message: m);
      }

      dev.log(r.body);

      return ActivationResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ActivationResponse.empty();
      return Service.handleError<ActivationResponse>(e, s, r);
    };

    return Http.doGet(path, params: params).then(c).catchError(e);
  }

  /// Create new user account
  /// by using e-mail address, password, name and username
  Future<SignUpResponse> signUp(
    String email,
    String password,
    String username,
    String name,
  ) {
    final path = '/account/create';
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'name': name,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SignUpResponse.bind(status: false, message: m);
      }

      return SignUpResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SignUpResponse.empty();
      return Service.handleError<SignUpResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }

  /// Check user session by using session code
  Future<SessionResponse> checkSession(String session) {
    final path = '/account/session';
    final body = {
      'session': session,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SessionResponse.bind(status: false, message: m);
      }

      return SessionResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SessionResponse.empty();
      return Service.handleError<SessionResponse>(e, s, r);
    };

    return Http.doPost(path, body: body).then(c).catchError(e);
  }
}

class SignInResponse extends BasicResponse {
  String session;

  bool activation = true;

  /// Create empty object
  SignInResponse.empty() : super.empty();

  /// Create only status and message
  SignInResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SignInResponse.fromJson(String input) {
    final json = super.fromJson(input);

    session = json['session'] ?? null;
    activation = json['activation'] ?? true;
  }
}

class ActivationResponse extends BasicResponse {
  bool expired = false;

  /// Create empty object
  ActivationResponse.empty() : super.empty();

  /// Create only status and message
  ActivationResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ActivationResponse.fromJson(String input) {
    final json = super.fromJson(input);

    expired = json['expired'] ?? false;
  }
}

class SignUpResponse extends BasicResponse {
  /// Create empty object
  SignUpResponse.empty() : super.empty();

  /// Create only status and message
  SignUpResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SignUpResponse.fromJson(String input) {
    super.fromJson(input);
  }
}

class SessionResponse extends BasicResponse {
  /// Create empty object
  SessionResponse.empty() : super.empty();

  /// Create only status and message
  SessionResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SessionResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
