import 'package:dio/dio.dart';
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/core/utils/map_extension.dart';

enum ApiStatus {
  success,
  failure,
}

class ApiResponse {
  ApiResponse({
    required this.isSuccessful,
    this.message,
    this.statusCode,
    this.data,
    this.responseObject,
  });

  final bool isSuccessful;
  String? message;
  int? statusCode;
  Response? responseObject;
  dynamic data;

  static ApiResponse response(Response response) {
    log.d(response.data);
    if (response.data is Map) {
      log.d(response.data);
      return ApiResponse(
        message: parseResponseMessage(response.data['message']),
        isSuccessful: (response.statusCode ?? 200) >= 200 &&
            (response.statusCode ?? 200) <= 299,
        data: response.data,
        statusCode: response.statusCode,
        responseObject: response,
      );
    } else {
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 299) {
        return ApiResponse(
          message: 'Success',
          isSuccessful: (response.statusCode ?? 200) >= 200 &&
              (response.statusCode ?? 200) <= 299,
          data: response.data,
          statusCode: response.statusCode,
          responseObject: response,
        );
      } else {
        return ApiResponse(
          message: parseResponseMessage(response.data['message']) ??
              'An error occurred, please try again later',
          isSuccessful: false,
          data: response.data,
          statusCode: response.statusCode,
          responseObject: response,
        );
      }
    }
  }
}

extension ApiError on DioException {
  ApiResponse toApiError() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return ApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.connectionError:
        return ApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.receiveTimeout:
        return ApiResponse(
          isSuccessful: false,
          message: 'Server took too long to respond, please try again later',
        );

      case DioExceptionType.sendTimeout:
        return ApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.badResponse:
        log.e(response?.data);

        if (response == null) {
          LoggerService.logError(
            error: response?.data,
            stackTrace: stackTrace,
            reason: 'Empty response',
            errorCode: response != null ? response?.statusCode ?? 500 : 500,
          );
        }

        // Handle 401 - Unauthorized

        if (response?.statusCode == 401 &&
            (response?.data['message'] ==
                    'Your session has expired. Please log in again.' ||
                response?.data['statusCode'] == 401)) {
          return ApiResponse(
            message: response?.data['message'] ?? 'Unauthorized access',
            isSuccessful: false,
            data: response?.data,
            statusCode: response?.statusCode,
            responseObject: response,
          );
        }

        if (response?.statusCode != null && response?.statusCode == 500) {
          LoggerService.logError(
            error: response?.data,
            stackTrace: stackTrace,
            reason: 'Bad response',
            errorCode: response != null ? response?.statusCode ?? 500 : 500,
          );
        }
        return ApiResponse(
          isSuccessful: false,
          message: response?.data['message'] ??
              'An error occurred, please try again later',
        );

      case DioExceptionType.cancel:
        return ApiResponse(
          isSuccessful: false,
          message: 'Request cancelled',
        );

      case DioExceptionType.unknown:
        LoggerService.logError(
          error: response?.data,
          stackTrace: stackTrace,
          reason: 'An error occurred, please try again later',
          errorCode: response?.statusCode ?? 600,
        );
        return ApiResponse(
          isSuccessful: false,
          message: 'An unknown error occurred, please try again later',
        );

      default:
        LoggerService.logError(
          error: response?.data,
          stackTrace: stackTrace,
          reason: 'An error occurred, please try again later',
          errorCode: response?.statusCode ?? 600,
        );
        return ApiResponse(
          isSuccessful: false,
          message: 'An unknown error occurred, please try again later',
        );
    }
  }

  CustomApiResponse toApiErrors() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return CustomApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.connectionError:
        return CustomApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.receiveTimeout:
        return CustomApiResponse(
          isSuccessful: false,
          message: 'Server took too long to respond, please try again later',
        );

      case DioExceptionType.sendTimeout:
        return CustomApiResponse(
          isSuccessful: false,
          message: 'Please check your internet connection or try again later',
        );

      case DioExceptionType.badResponse:
        log.e(response?.data);

        if (response == null) {
          LoggerService.logError(
            error: response?.data,
            stackTrace: stackTrace,
            reason: 'Empty response',
            errorCode: response != null ? response?.statusCode ?? 500 : 500,
          );
        }

        // Handle 401 - Unauthorized

        if (response?.statusCode == 401 &&
            (response?.data['message'] ==
                    'Your session has expired. Please log in again.' ||
                response?.data['statusCode'] == 401)) {
          return CustomApiResponse(
            message: response?.data['message'] ?? 'Unauthorized access',
            isSuccessful: false,
            data: response?.data,
            statusCode: response?.statusCode,
            responseObject: response,
          );
        }

        if (response?.statusCode != null && response?.statusCode == 500) {
          LoggerService.logError(
            error: response?.data,
            stackTrace: stackTrace,
            reason: 'Bad response',
            errorCode: response != null ? response?.statusCode ?? 500 : 500,
          );
        }
        return CustomApiResponse(
          isSuccessful: false,
          message: response?.data['message'] ??
              'An error occurred, please try again later',
        );

      case DioExceptionType.cancel:
        return CustomApiResponse(
          isSuccessful: false,
          message: 'Request cancelled',
        );

      case DioExceptionType.unknown:
        LoggerService.logError(
          error: response?.data,
          stackTrace: stackTrace,
          reason: 'An error occurred, please try again later',
          errorCode: response?.statusCode ?? 600,
        );
        return CustomApiResponse(
          isSuccessful: false,
          message: 'An unknown error occurred, please try again later',
        );

      default:
        LoggerService.logError(
          error: response?.data,
          stackTrace: stackTrace,
          reason: 'An error occurred, please try again later',
          errorCode: response?.statusCode ?? 600,
        );
        return CustomApiResponse(
          isSuccessful: false,
          message: 'An unknown error occurred, please try again later',
        );
    }
  }
}

class CustomApiResponse {
  CustomApiResponse({
    required this.isSuccessful,
    this.message,
    this.statusCode,
    this.data,
    this.responseObject,
  });

  final bool isSuccessful;
  String? message;
  int? statusCode;
  Response? responseObject;
  dynamic data;

  static CustomApiResponse response(Response response) {
    log.d(response.data);

    String? extractMessage(dynamic responseData) {
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message')) {
          final messageValue = responseData['message'];
          // Safely extract the message as String if it's not a Map
          if (messageValue is String) {
            return messageValue;
          } else if (messageValue is Map<String, dynamic> &&
              messageValue['response'] is Map<String, dynamic>) {
            // Navigate to nested "response" message
            return (messageValue['response'] as Map<String, dynamic>)['message']
                as String?;
          }
        }
      }
      return null; // Default to null if no valid message is found
    }

    final message = extractMessage(response.data) ?? 'Success';

    final isSuccess = (response.statusCode ?? 200) >= 200 &&
        (response.statusCode ?? 200) <= 299;

    return CustomApiResponse(
      message:
          isSuccess ? message : 'An error occurred, please try again later',
      isSuccessful: isSuccess,
      data: response.data,
      statusCode: response.statusCode,
      responseObject: response,
    );
  }
}
