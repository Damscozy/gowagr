import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gowagr/core/config/local_storage.dart';
import 'package:gowagr/core/utils/app_colors.dart';
import 'package:gowagr/data/notifier/event_notifier.dart';
import 'package:gowagr/presentation/widgets/events_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(eventViewModelProvider.notifier);

      final cachedEvents = HiveStorage.getCachedEventsModel();
      if (cachedEvents != null && cachedEvents.events.isNotEmpty == true) {
        notifier.setEventsFromCache(cachedEvents);
      }

      notifier.fetchEvents();
    });

    _scrollController.addListener(() {
      final notifier = ref.read(eventViewModelProvider.notifier);
      final state = ref.read(eventViewModelProvider);

      if (!state.isLoadingEvents &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        notifier.fetchEvents(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refreshView(EventViewModel notifier) async {
    await notifier.refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventViewModelProvider);
    final notifier = ref.read(eventViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.white,
          onRefresh: () => refreshView(notifier),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              SizedBox(height: 20.h),
              buildTabs(),
              SizedBox(height: 20.h),
              buildSearchBar(ref, notifier),
              SizedBox(height: 10.h),
              buildCategorySelector(ref, state, notifier),
              Expanded(
                child: buildEventList(state, _scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
