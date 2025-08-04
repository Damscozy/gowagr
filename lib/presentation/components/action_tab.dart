import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  final Color fillColor;

  const ActionButton({
    super.key,
    required this.label,
    required this.price,
    required this.color,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            "$label - $price",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
