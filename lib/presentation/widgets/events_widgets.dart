import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gowagr/core/utils/app_colors.dart';
import 'package:gowagr/data/notifier/event_notifier.dart';
import 'package:gowagr/data/state/event_state.dart';
import 'package:gowagr/presentation/components/event_card.dart';
import 'package:gowagr/presentation/components/tab_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum EventCategory {
  trending("Trending", "assets/svgs/trending.svg"),
  watchlist("Watchlist", "assets/svgs/watchlist.svg"),
  entertainment("Entertainment 🎶", null),
  sports("Sports ⚽️", null);

  final String label;
  final String? iconPath;

  const EventCategory(this.label, this.iconPath);

  String? get apiParam {
    switch (this) {
      case EventCategory.trending:
        return "trending";
      case EventCategory.watchlist:
        return "watchlist";
      case EventCategory.entertainment:
        return "entertainment";
      case EventCategory.sports:
        return "sports";
    }
  }

  bool get isTrending => this == EventCategory.trending;
}

Widget buildHeader() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Row(
      children: [
        SvgPicture.asset('assets/svgs/logo.svg', height: 40.h),
        const Spacer(),
      ],
    ),
  );
}

Widget buildTabs() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(
      children: [
        TabItem(label: "Explore", isActive: true),
        TabItem(label: "Portfolio"),
        TabItem(label: "Activity"),
      ],
    ),
  );
}

Widget buildSearchBar(
  WidgetRef ref,
  EventViewModel notifier,
) {
  return Padding(
    padding: EdgeInsets.all(16.w),
    child: TextField(
      onChanged: (value) => notifier.updateSearchQuery(value.toLowerCase()),
      onSubmitted: (value) => notifier.updateSearchQuery(value.toLowerCase()),
      decoration: InputDecoration(
        hintText: "Search for a market",
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.searchColor,
        ),
        hintStyle: TextStyle(
          color: AppColors.searchColor,
          fontSize: 14.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: AppColors.searchColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            width: 1.w,
            color: AppColors.searchColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            width: 1.w,
            color: AppColors.primary,
          ),
        ),
      ),
    ),
  );
}

Widget buildCategorySelector(
  WidgetRef ref,
  EventViewState state,
  EventViewModel notifier,
) {
  return SizedBox(
    height: 40.h,
    child: ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      itemCount: EventCategory.values.length,
      separatorBuilder: (_, __) => SizedBox(width: 8.w),
      itemBuilder: (context, index) {
        final category = EventCategory.values[index];
        final isActive = state.selectedCategory == category;

        final iconWidget = category.iconPath != null
            ? SvgPicture.asset(
                category.iconPath!,
                colorFilter: ColorFilter.mode(
                  isActive ? AppColors.white : AppColors.black,
                  BlendMode.srcIn,
                ),
              )
            : null;

        final textWidget = Text(
          category.label,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        );

        final children = isActive
            ? [
                if (iconWidget != null) ...[iconWidget, SizedBox(width: 4.w)],
                textWidget,
              ]
            : [
                textWidget,
                if (iconWidget != null) ...[SizedBox(width: 4.w), iconWidget],
              ];

        return GestureDetector(
          onTap: () => notifier.updateCategory(category),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.categoryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: children),
          ),
        );
      },
    ),
  );
}

Widget buildEventList(
  EventViewState state,
  ScrollController scrollController,
) {
  final isWatchlist = state.selectedCategory == EventCategory.watchlist;

  if (state.isLoadingEvents && (state.eventsModel?.events.isEmpty ?? true)) {
    return _buildLoader();
  }

  if (state.errorMessage?.isNotEmpty == true) {
    return _errorMessage(state.errorMessage!, color: Colors.red);
  }

  if (state.eventsModel?.events.isEmpty ?? true) {
    return Center(
      child: Text(
        isWatchlist ? "No events currently watched" : "No events found",
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  return ListView.builder(
    controller: scrollController,
    padding: EdgeInsets.all(16.sp),
    itemCount:
        state.eventsModel!.events.length + (state.isLoadingEvents ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == state.eventsModel!.events.length && state.isLoadingEvents) {
        return _buildLoader();
      }

      final event = state.eventsModel!.events[index];
      final isCombined = event.markets.length > 1;

      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: isCombined
            ? CombinedEventCard(event: event)
            : SingleEventCard(event: event),
      );
    },
  );
}

Widget _errorMessage(String text, {Color color = Colors.black}) => Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: color),
        textAlign: TextAlign.center,
      ),
    );

Widget _buildLoader() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.w),
    child: Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator(color: AppColors.primary)
          : CircularProgressIndicator(color: AppColors.primary),
    ),
  );
}
