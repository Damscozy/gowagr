import 'package:gowagr/core/config/local_storage.dart';
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/data/impl/event_impl.dart';
import 'package:gowagr/data/model/event_model.dart';
import 'package:gowagr/data/state/event_state.dart';
import 'package:gowagr/presentation/widgets/events_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final eventViewModelProvider =
    NotifierProvider<EventViewModel, EventViewState>(() => EventViewModel());

class EventViewModel extends Notifier<EventViewState> {
  @override
  EventViewState build() => const EventViewState();

  EventApiImpl get _repo => ref.read(appRepoProvider);

  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
    );
    fetchEvents();
  }

  void updateCategory(EventCategory category) async {
    state = state.copyWith(selectedCategory: category, currentPage: 1);

    if (category == EventCategory.watchlist) {
      final watchlistIds = await HiveStorage.getWatchlist();
      final allCachedEvents = HiveStorage.getCachedEventsModel()?.events ?? [];
      final filteredEvents =
          allCachedEvents.where((e) => watchlistIds.contains(e.id)).toList();

      state = state.copyWith(
        eventsModel: EventsModel(events: filteredEvents),
      );
      return;
    }

    try {
      await fetchEvents();
    } catch (_) {
      final cached = HiveStorage.getCachedEventsModel();
      if (cached != null) {
        state = state.copyWith(eventsModel: cached);
      }
    }
  }

  void resetPagination() async {
    state = state.copyWith(
      currentPage: 1,
      hasMore: true,
      eventsModel: null,
    );
    await fetchEvents();
  }

  void setEventsFromCache(EventsModel cachedEvents) {
    state = state.copyWith(
      eventsModel: cachedEvents,
    );
  }

  Future<void> fetchEvents({bool loadMore = false}) async {
    if (state.isLoadingEvents || (!state.hasMore && loadMore)) return;

    if (!loadMore && state.eventsModel == null) {
      final cached = HiveStorage.getCachedEventsModel();
      if (cached != null && cached.events.isNotEmpty == true) {
        log.d('Loaded ${cached.events.length} cached events from Hive');
        state = state.copyWith(eventsModel: cached);
      }
    }

    state = state.copyWith(isLoadingEvents: true);

    try {
      final page = loadMore ? state.currentPage + 1 : 1;
      final selectedCategory = state.selectedCategory;

      final queryParams = {
        'page': page.toString(),
        'size': '10',
        if (state.searchQuery.isNotEmpty) 'keyword': state.searchQuery,
        if (!selectedCategory.isTrending && selectedCategory.apiParam != null)
          'category': selectedCategory.apiParam,
        if (selectedCategory.isTrending) 'trending': 'true',
      };

      log.d('Fetching events with params: $queryParams');

      final res = await _repo.fetchPublicEvents(queryParameters: queryParams);

      if (res.isSuccessful && res.data != null) {
        final newEvents = EventsModel.fromJson(
          Map<String, dynamic>.from(res.data),
        );

        final mergedEvents = loadMore && state.eventsModel != null
            ? EventsModel(
                events: [
                  ...state.eventsModel!.events,
                  ...newEvents.events,
                ],
                pagination: newEvents.pagination,
              )
            : newEvents;

        state = state.copyWith(
          eventsModel: mergedEvents,
          currentPage: page,
          hasMore: newEvents.events.isNotEmpty,
          errorMessage: null,
        );

        // Save updated events to Hive
        if (!loadMore) {
          HiveStorage.cacheEventsIfFresh(mergedEvents);
        }
        HiveStorage.cacheEventsIfFresh(mergedEvents);
        log.d('Fetched ${newEvents.events.length} events');
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? 'Error fetching events',
        );
        log.d('Error Message: ${res.message}');
      }
    } catch (e, s) {
      log.e('Error fetching events', error: e, stackTrace: s);
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoadingEvents: false);
    }
  }

  Future<void> refreshEvents() async {
    final selectedCategory = state.selectedCategory;

    if (selectedCategory == EventCategory.watchlist) {
      final watchlistIds = await HiveStorage.getWatchlist();
      final allCachedEvents = HiveStorage.getCachedEventsModel()?.events ?? [];
      final filteredEvents =
          allCachedEvents.where((e) => watchlistIds.contains(e.id)).toList();

      state = state.copyWith(
        eventsModel: EventsModel(events: filteredEvents),
      );
      return;
    }

    try {
      await fetchEvents();
    } catch (e) {
      log.e("Refresh failed, using cache", error: e);
      final cached = HiveStorage.getCachedEventsModel();
      if (cached != null) {
        state = state.copyWith(eventsModel: cached);
      }
    }
  }
}
