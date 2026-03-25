import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static String get projectId => dotenv.env['PROJECT_ID'] ?? '';
  static const String fcmBaseUrl = 'https://fcm.googleapis.com/';
  static String get fcmEndPoint => 'v1/projects/$projectId/messages:send';
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "Mozilla/5.0",
  };
  static const int receiveTimeout = 30;
  static const int connectTimeout = 10;
}
