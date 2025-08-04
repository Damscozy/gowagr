import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gowagr/core/config/local_storage.dart';
import 'package:gowagr/core/utils/app_colors.dart';
import 'package:gowagr/core/utils/map_extension.dart';
import 'package:gowagr/data/model/event_model.dart';
import 'package:gowagr/presentation/components/action_tab.dart';

class SingleEventCard extends StatefulWidget {
  final Event event;
  const SingleEventCard({super.key, required this.event});

  @override
  State<SingleEventCard> createState() => _SingleEventCardState();
}

class _SingleEventCardState extends State<SingleEventCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventCardHeader(event: widget.event),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: "Buy Yes",
                  price: widget.event.supportedCurrencies
                          .contains(SupportedCurrency.ngn)
                      ? "₦${widget.event.markets.first.yesBuyPrice ?? 0}"
                      : "\$${widget.event.markets.first.yesBuyPrice ?? 0}",
                  color: AppColors.primary,
                  fillColor: AppColors.secondary,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: ActionButton(
                  label: "Buy No",
                  price: widget.event.supportedCurrencies
                          .contains(SupportedCurrency.ngn)
                      ? "₦${widget.event.markets.first.noBuyPrice ?? 0}"
                      : "\$${widget.event.markets.first.noBuyPrice ?? 0}",
                  color: AppColors.redColor,
                  fillColor: AppColors.redColor2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfitColumn(
                cost: formatCurrency(
                  widget.event.supportedCurrencies
                      .contains(SupportedCurrency.ngn),
                  widget.event.markets.first.yesPriceForEstimate ?? 0,
                ),
                profit: formatCurrency(
                  widget.event.supportedCurrencies
                      .contains(SupportedCurrency.ngn),
                  widget.event.markets.first.yesProfitForEstimate ?? 0,
                ),
                profitColor: AppColors.greenColor,
              ),
              _buildProfitColumn(
                cost: formatCurrency(
                  widget.event.supportedCurrencies
                      .contains(SupportedCurrency.ngn),
                  widget.event.markets.first.noPriceForEstimate ?? 0,
                ),
                profit: formatCurrency(
                  widget.event.supportedCurrencies
                      .contains(SupportedCurrency.ngn),
                  widget.event.markets.first.noProfitForEstimate ?? 0,
                ),
                profitColor: AppColors.greenColor,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          EventCardFooter(event: widget.event),
        ],
      ),
    );
  }

  Widget _buildProfitColumn({
    required String cost,
    required String profit,
    required Color profitColor,
  }) {
    return Row(
      children: [
        Text(
          cost,
          style: TextStyle(
            color: AppColors.greyColor,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.arrow_right_alt, size: 16.sp, color: AppColors.greyColor),
        SizedBox(width: 4.w),
        Text(
          profit,
          style: TextStyle(
            color: profitColor,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class CombinedEventCard extends StatelessWidget {
  final Event event;
  const CombinedEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventCardHeader(event: event),
          SizedBox(height: 15.h),
          ...event.markets.map(
            (market) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1.sw * .4),
                    child: Text(
                      market.title ?? "",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.marketColor,
                      ),
                    ),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      ActionButton(
                        label: "Yes",
                        price: event.supportedCurrencies
                                .contains(SupportedCurrency.ngn)
                            ? "₦${market.yesBuyPrice ?? 0}"
                            : "\$${market.yesBuyPrice ?? 0}",
                        color: AppColors.primary,
                        fillColor: AppColors.secondary,
                        compact: true,
                      ),
                      SizedBox(height: 5.h),
                      ActionButton(
                        label: "No",
                        price: event.supportedCurrencies
                                .contains(SupportedCurrency.ngn)
                            ? "₦${market.noBuyPrice ?? 0}"
                            : "\$${market.noBuyPrice ?? 0}",
                        color: AppColors.redColor,
                        fillColor: AppColors.redColor2,
                        compact: true,
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          EventCardFooter(event: event),
        ],
      ),
    );
  }
}

class EventCardHeader extends StatelessWidget {
  final Event event;

  const EventCardHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: CachedNetworkImage(
            imageUrl: event.imageUrl ?? "",
            fit: BoxFit.cover,
            width: 40.w,
            height: 40.h,
            placeholder: (_, __) => Icon(
              Icons.image,
              size: 20.sp,
              color: AppColors.greyColor,
            ),
            errorWidget: (_, __, ___) => Icon(
              Icons.error,
              size: 20.sp,
              color: AppColors.redColor,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            event.title ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class EventCardFooter extends StatefulWidget {
  final Event event;

  const EventCardFooter({super.key, required this.event});

  @override
  State<EventCardFooter> createState() => _EventCardFooterState();
}

class _EventCardFooterState extends State<EventCardFooter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/svgs/trades.svg',
            colorFilter:
                ColorFilter.mode(AppColors.greyColor, BlendMode.srcIn)),
        SizedBox(width: 6.w),
        Text(
          "₦${(widget.event.totalVolume ?? 0).toStringAsFixed(1)}M",
          style: TextStyle(
            color: AppColors.greyColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        Text(
          widget.event.resolutionDate != null
              ? "Ends ${widget.event.resolutionDate!.day} ${monthName(widget.event.resolutionDate!.month)}"
              : "",
          style: TextStyle(color: AppColors.greyColor, fontSize: 12.sp),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () async {
            await HiveStorage.toggleWatchlist(widget.event.id!);
            setState(() {});
          },
          child: FutureBuilder<bool>(
            future: HiveStorage.isInWatchlist(widget.event.id!),
            builder: (context, snapshot) {
              final isInWatchlist = snapshot.data ?? false;
              final iconPath = widget.event.type == EventType.combinedMarkets
                  ? 'assets/svgs/favourite.svg'
                  : 'assets/svgs/watchlist.svg';

              return SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  isInWatchlist ? AppColors.primary : AppColors.greyColor,
                  BlendMode.srcIn,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
