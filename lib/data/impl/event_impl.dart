import 'package:gowagr/core/config/endpoints.dart';
import 'package:gowagr/core/services/api_response.dart';
import 'package:gowagr/core/services/api_service.dart';
import 'package:gowagr/data/repo/event_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRepoProvider = Provider<EventApiImpl>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return EventApiImpl(apiService: apiService);
});

/// Implementation of Event repository
class EventApiImpl implements EventRepository {
  final ApiService apiService;

  EventApiImpl({required this.apiService});

  @override
  Future<ApiResponse> fetchPublicEvents({
    required Map<String, dynamic> queryParameters,
  }) {
    return apiService.getData(
      Endpoints.eventsUrl,
      queryParameters: queryParameters,
    );
  }
}
