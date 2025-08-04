import 'package:gowagr/core/services/api_response.dart';

abstract class EventRepository {
  Future<ApiResponse> fetchPublicEvents({
    required Map<String, dynamic> queryParameters,
  });
}
