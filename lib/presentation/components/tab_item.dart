import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gowagr/core/utils/app_colors.dart';

class TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  const TabItem({
    super.key,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.bold,
          color: isActive ? AppColors.textColor : AppColors.greyColor,
        ),
      ),
    );
  }
}
