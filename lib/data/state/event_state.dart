import 'package:gowagr/data/model/event_model.dart';
import 'package:gowagr/presentation/widgets/events_widgets.dart';

class EventViewState {
  final EventsModel? eventsModel;
  final bool isLoadingEvents;
  final String searchQuery;
  final EventCategory selectedCategory;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const EventViewState({
    this.eventsModel,
    this.isLoadingEvents = false,
    this.searchQuery = '',
    this.selectedCategory = EventCategory.trending,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  EventViewState copyWith({
    EventsModel? eventsModel,
    bool? isLoadingEvents,
    String? searchQuery,
    EventCategory? selectedCategory,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return EventViewState(
      eventsModel: eventsModel ?? this.eventsModel,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
