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

  /// Activate account by using activation code and session token
  Future<ActivateResponse> activate(String token, String code) {
    final path = '/account/activate';
    final body = {
      'code': code.toString(),
      'token': token,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ActivateResponse.bind(status: false, message: m);
      }

      dev.log(r.body);

      return ActivateResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ActivateResponse.empty();
      return Service.handleError<ActivateResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }

  /// Send activation code by using activation code and session token
  Future<ActivationResponse> activation(String token) {
    final path = '/account/activation';
    final body = {
      'token': token,
    };

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

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
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
  bool activation = true;

  String session;

  String token;

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

    token = json['token'] ?? null;
    session = json['session'] ?? null;
    activation = json['activation'] ?? true;
  }
}

class ActivateResponse extends BasicResponse {
  bool expired = false;

  String session;

  /// Create empty object
  ActivateResponse.empty() : super.empty();

  /// Create only status and message
  ActivateResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ActivateResponse.fromJson(String input) {
    final json = super.fromJson(input);

    session = json['session'] ?? null;
    expired = json['expired'] ?? false;
  }
}

class ActivationResponse extends BasicResponse {
  String token;

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

    token = json['token'] ?? null;
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
