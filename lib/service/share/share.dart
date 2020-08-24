import 'dart:developer' as dev;
import 'dart:io';

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/http.dart';

class ShareService extends Service {
  /// Create new post
  static Future<SharePostResponse> call({
    String session,
    bool disposible,
    bool restricted,
    String comment,
    double device,
    int size,
    List<File> files,
    List<double> scales,
    List<String> users,
  }) {
    final path = '/shares/post';
    final headers = {
      Http.TOKEN_HEADER: session,
    };
    final body = <String, dynamic>{
      'disposible': disposible,
      'restricted': restricted,
      'comment': comment,
      'device': device,
      'size': size,
    };

    // Create users list
    for (int i = 0; i < users.length; i++) {
      body['users-$i'] = users[i];
    }

    // Create scales for photo and video resize
    for (int i = 0; i < scales.length; i++) {
      body['scales-$i'] = scales[i];
    }

    // Create post files which are photos and videos
    for (int i = 0; i < files.length; i++) {
      final ext = files[i].path.split('.').last;
      final type = ext == 'mp4' ? AppConst.video : AppConst.photo;

      body['types-$i'] = type;
      body['files-$i'] = files[i];
    }

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SharePostResponse.bind(status: false, message: m);
      }

      return SharePostResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SharePostResponse.empty();

      dev.log('Post share error.', error: e, stackTrace: s);

      return Service.handleError<SharePostResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      headers: headers,
      type: Http.MULTIPART,
      timeout: Duration(seconds: 60),
    );

    return r.then(c).catchError(e);
  }
}

class SharePostResponse extends BasicResponse {
  String code;

  /// Create empty object
  SharePostResponse.empty() : super.empty();

  /// Create only status and message
  SharePostResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SharePostResponse.fromJson(String input) {
    final json = super.fromJson(input);

    code = json['code'] ?? null;
  }
}
