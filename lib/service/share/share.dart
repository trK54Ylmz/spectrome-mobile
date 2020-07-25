import 'dart:developer' as dev;
import 'dart:io';

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/http.dart';

class ShareService extends Service {
  /// Create new post
  static Future<SharePostResponse> call(
    String comment,
    List<String> tags,
    List<String> files,
  ) {
    final path = '/shares/post';
    final body = <String, dynamic>{
      'comment': comment,
    };

    // Add tags as list
    for (int i = 0; i < tags.length; i++) {
      body['tag-$i'] = tags[i];
    }

    for (int i = 0; i < files.length; i++) {
      final type = files[i].endsWith('mp4') ? AppConst.video : AppConst.photo;

      body['type-$i'] = type;
      body['file-$i'] = new File(files[i]);
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
      type: Http.FORM,
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
