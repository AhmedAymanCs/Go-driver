import 'package:dio/dio.dart';

class DioHelper {
  final Dio _dio;

  DioHelper(this._dio);

  Future<Response> postData({
    required String endPoint,
    required String accessToken,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(
      endPoint,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
  }
}
