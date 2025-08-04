import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  final Color fillColor;
  final bool compact;
  final double fixedWidth;

  const ActionButton({
    super.key,
    required this.label,
    required this.price,
    required this.color,
    required this.fillColor,
    this.compact = false,
    this.fixedWidth = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fixedWidth.w,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8.w : 12.w,
            vertical: compact ? 6.h : 10.h,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
              color: color,
              width: .5.w,
            ),
          ),
          child: FittedBox(
            // 👈 keeps text from overflowing
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: compact ? 11.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  price,
                  style: TextStyle(
                    color: color,
                    fontSize: compact ? 11.sp : 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
