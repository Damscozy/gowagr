import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gowagr/core/utils/app_colors.dart';
import 'package:gowagr/core/utils/map_extension.dart';
import 'package:gowagr/data/model/event_model.dart';
import 'package:gowagr/presentation/components/action_tab.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(event.imageUrl ?? ""),
                radius: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  event.title ?? "",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ActionButton(
                  label: "Buy Yes",
                  price: event.supportedCurrencies
                          .contains(SupportedCurrency.ngn)
                      ? "₦${event.markets.isNotEmpty ? event.markets.first.yesBuyPrice ?? 0 : 0}"
                      : "\$${event.markets.isNotEmpty ? event.markets.first.yesBuyPrice ?? 0 : 0}",
                  color: AppColors.primary,
                  fillColor: AppColors.secondary,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: ActionButton(
                  label: "Buy No",
                  price: event.supportedCurrencies
                          .contains(SupportedCurrency.ngn)
                      ? "₦${event.markets.isNotEmpty ? event.markets.first.noBuyPrice ?? 0 : 0}"
                      : "\$${event.markets.isNotEmpty ? event.markets.first.noBuyPrice ?? 0 : 0}",
                  color: AppColors.redColor,
                  fillColor: AppColors.redColor2,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('assets/svgs/trades.svg'),
              SizedBox(width: 10.w),
              Text(
                "${event.totalOrders ?? 0} Trades",
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 12.sp,
                ),
              ),
              Spacer(),
              Text(
                event.resolutionDate != null
                    ? "Ends ${event.resolutionDate!.day} ${monthName(event.resolutionDate!.month)}"
                    : "",
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {},
                child: event.type == EventType.combinedMarkets
                    ? SvgPicture.asset(
                        'assets/svgs/favourite.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.greyColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svgs/watchlist.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.greyColor,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
