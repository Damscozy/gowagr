import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gowagr/core/utils/app_colors.dart';
import 'package:gowagr/data/notifier/event_notifier.dart';
import 'package:gowagr/data/state/event_state.dart';
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
      onChanged: (value) => notifier.updateSearchQuery(value),
      onSubmitted: (value) => notifier.updateSearchQuery(value),
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

        return GestureDetector(
          onTap: () => notifier.updateCategory(category),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.categoryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isActive
                  ? [
                      if (iconWidget != null) ...[
                        iconWidget,
                        SizedBox(width: 4.w),
                      ],
                      textWidget,
                    ]
                  : [
                      textWidget,
                      if (iconWidget != null) ...[
                        SizedBox(width: 4.w),
                        iconWidget,
                      ],
                    ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(width: 8.w),
      itemCount: EventCategory.values.length,
    ),
  );
}
