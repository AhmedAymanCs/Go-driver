import 'package:flutter/services.dart';
import 'package:go_driver/core/database/remote/networking/api_constant.dart';
import 'package:go_driver/core/database/remote/networking/dio_helper.dart';
import 'package:go_driver/core/di/service_locator.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  Future<String> _getAccessToken() async {
    final jsonString = await rootBundle.loadString('assets/json/key.json');

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(
      jsonString,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(
      accountCredentials,
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  Future<void> sendNotification({
    required String? token,
    required String? title,
    required String? body,
  }) async {
    final String accessToken = await _getAccessToken();
    getIt<DioHelper>().postData(
      endPoint: ApiConstant.fcmEndPoint,
      accessToken: accessToken,
      data: {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
        },
      },
    );
  }
}
