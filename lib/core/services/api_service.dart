import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:gowagr/core/config/endpoints.dart';
import 'package:gowagr/core/config/local_storage.dart';
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/core/services/api_response.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService(ref));
final uploadProgressProvider = StateProvider<double>((ref) => 0);

class ApiService {
  Ref ref;
  ApiService(this.ref) {
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log.d(options.uri);
          log.d(
              'request: ${options.method}, path: ${options.path}, params :${options.queryParameters}');
          log.d(options.data);
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          log.d(
            'realUrl: ${response.realUri}, statusCode: ${response.statusCode}, data: ${response.data}',
          );

          if (response.statusCode == 401) {
            //   AppRouter.router.goNamed(Routes.welcomeRoute);
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          log.d(
            'error: ${e.message}, statusCode: ${e.response?.statusCode}  data: ${e.response?.data}',
          );
          log.d(e.response?.data);
          if (e.response?.statusCode == 401) {
            //   AppRouter.router.goNamed(Routes.welcomeRoute);
          }
          return handler.next(e);
        },
      ),
    );
  }

  // CancelToken token = CancelToken();
  final Dio _client = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<String?> getDeviceData() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceType;

    if (Platform.isAndroid) {
      String? name = (await deviceInfo.androidInfo).name;
      String? model = (await deviceInfo.androidInfo).model;
      deviceType = '$name - $model';
    } else if (Platform.isIOS) {
      String? name = (await deviceInfo.iosInfo).name;
      String? model = (await deviceInfo.iosInfo).model;
      deviceType = '$name - $model';
    }

    return deviceType;
  }

  Future<ApiResponse> postData(
    String url, {
    bool hasHeader = false,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool cancelFormerRequests = false,
    String? contentType,
    Dio? customClient,
    bool isRegistration = false,
    bool hasXAuthToken = false,
  }) async {
    try {
      final String? deviceType = await getDeviceData();
      final head = {
        'Authorization': 'Bearer ${HiveStorage.accessToken}',
        if (deviceType != null) 'x-user-agent': deviceType
      };
      log.d('header: $head');
      final request = await (customClient ?? _client).post(
        url,
        data: body,
        onSendProgress: (count, total) {
          double progress = ((count / total) * 100).floor().toDouble();
          ref.read(uploadProgressProvider.notifier).state = progress;
        },
        options: Options(
          method: 'POST',
          headers: hasHeader ? head : null,
          contentType: contentType ?? 'application/json',
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );

      return ApiResponse.response(request);
    } on DioException catch (e, s) {
      log
        ..d('Dio Exception')
        ..d(e, stackTrace: s);
      log.d('API CALL ERROR $e');

      return e.toApiError();
    } on SocketException catch (e, s) {
      log
        ..d('socket Exception')
        ..d(e, stackTrace: s);
      return ApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } on Exception catch (e, s) {
      log
        ..d('Exception')
        ..d(e, stackTrace: s);
      return ApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<CustomApiResponse> customPostData(
    String url, {
    bool hasHeader = false,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool cancelFormerRequests = false,
    String? contentType,
    Dio? customClient,
    bool isRegistration = false,
    bool hasXAuthToken = false,
  }) async {
    try {
      final String? deviceType = await getDeviceData();

      final head = {
        'Authorization': 'Bearer ${HiveStorage.accessToken}',
        if (deviceType != null) 'x-user-agent': deviceType
      };
      log.d('header: $head');
      final request = await (customClient ?? _client).post(
        url,
        data: body,
        onSendProgress: (count, total) {
          double progress = ((count / total) * 100).floor().toDouble();
          ref.read(uploadProgressProvider.notifier).state = progress;
        },
        options: Options(
          method: 'POST',
          headers: hasHeader ? head : null,
          contentType: contentType ?? 'application/json',
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );

      return CustomApiResponse.response(request);
    } on DioException catch (e, s) {
      log
        ..d('Dio Exception')
        ..d(e, stackTrace: s);
      log.d('API CALL ERROR $e');
      return e.toApiErrors();
    } on SocketException catch (e, s) {
      log
        ..d('socket Exception')
        ..d(e, stackTrace: s);
      return CustomApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } on Exception catch (e, s) {
      log
        ..d('Exception')
        ..d(e, stackTrace: s);
      return CustomApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> deleteData(
    String url, {
    bool hasHeader = false,
    dynamic body,
    bool cancelFormerRequests = false,
    Dio? customClient,
  }) async {
    final String? deviceType = await getDeviceData();

    final head = {
      'Authorization': 'Bearer ${HiveStorage.accessToken}',
      if (deviceType != null) 'x-user-agent': deviceType
    };
    log.d('header: $head');

    try {
      final request = await (customClient ?? _client).delete(
        url,
        data: body,
        options: Options(
          method: 'DELETE',
          headers: hasHeader ? head : null,
          contentType: 'application/json',
        ),
      );
      return ApiResponse.response(request);
    } on DioException catch (e, s) {
      log.d(e, stackTrace: s);
      return e.toApiError();
    } on SocketException {
      return ApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } on Exception catch (e) {
      return ApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> putData(
    String url, {
    bool hasHeader = false,
    dynamic body,
    bool cancelFormerRequests = false,
    Dio? customClient,
    Map<String, dynamic>? queryParameter,
    bool isOtpToken = false,
    bool isChannelInt = false,
  }) async {
    final String? deviceType = await getDeviceData();

    final head = {
      'Authorization': 'Bearer ${HiveStorage.accessToken}',
      if (deviceType != null) 'x-user-agent': deviceType
    };

    log.d('header: $head');
    try {
      final request = await (customClient ?? _client).put(
        url,
        data: body,
        queryParameters: queryParameter,
        options: Options(
          method: 'PUT',
          headers: hasHeader ? head : null,
          contentType: 'application/json',
        ),
      );
      return ApiResponse.response(request);
    } on DioException catch (e, s) {
      log.d(e, stackTrace: s);
      return e.toApiError();
    } on SocketException {
      return ApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } on Exception catch (e) {
      return ApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> patchData(
    String url, {
    bool hasHeader = false,
    dynamic body,
    bool cancelFormerRequests = false,
    Dio? customClient,
  }) async {
    final String? deviceType = await getDeviceData();

    final head = {
      'Authorization': 'Bearer ${HiveStorage.accessToken}',
      if (deviceType != null) 'x-user-agent': deviceType
    };
    log.d('header: $head');
    try {
      final request = await (customClient ?? _client).patch(
        url,
        data: body,
        options: Options(
          method: 'PATCH',
          headers: hasHeader ? head : null,
          contentType: 'application/json',
        ),
      );
      return ApiResponse.response(request);
    } on DioException catch (e, s) {
      log.d(e, stackTrace: s);
      return e.toApiError();
    } on SocketException {
      return ApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } catch (e) {
      return ApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> getData(
    String url, {
    bool hasHeader = false,
    bool cancelFormerRequests = false,
    Dio? customClient,
    Map<String, dynamic>? queryParameters,
    bool isRefreshing = false,
    String? contentType,
  }) async {
    try {
      final String? deviceType = await getDeviceData();

      final head = {
        'Authorization': 'Bearer ${HiveStorage.accessToken}',
        if (deviceType != null) 'x-user-agent': deviceType
      };
      log.d('header: $head');
      final request = await (customClient ?? _client).get(
        url,
        queryParameters: queryParameters,
        options: Options(
          method: 'GET',
          headers: hasHeader ? head : null,
          contentType: contentType ?? 'application/json',
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );
      return ApiResponse.response(request);
    } on DioException catch (e, s) {
      log.d(e, stackTrace: s);
      return e.toApiError();
    } on SocketException {
      return ApiResponse(
        isSuccessful: false,
        message: 'Please check your internet connection or try again later',
      );
    } catch (e) {
      return ApiResponse(
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  /// retry
  Future<Response<dynamic>> retry(RequestOptions requestOption) {
    final option = Options(
      method: requestOption.method,
      headers: requestOption.headers,
      sendTimeout: requestOption.sendTimeout,
    );
    return _client.request(
      requestOption.path,
      data: requestOption.data,
      queryParameters: requestOption.queryParameters,
      options: option,
    );
  }

  /// retry
  Future<Response<dynamic>> retryOnResponse({
    required String method,
    required Map<String, dynamic> headers,
    required int? sendoutTime,
    required Object? data,
    required Map<String, dynamic>? queryParameters,
  }) {
    final option = Options(
      method: method,
      headers: headers,
      sendTimeout: Duration(seconds: sendoutTime ?? 30),
    );
    return _client.request(
      Endpoints.baseUrl,
      data: data,
      queryParameters: queryParameters,
      options: option,
    );
  }
}
