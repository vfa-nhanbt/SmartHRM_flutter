import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/styles.dart';

class HomeClock extends StatefulWidget {
  const HomeClock({Key? key}) : super(key: key);

  @override
  State<HomeClock> createState() => _HomeClockState();
}

class _HomeClockState extends State<HomeClock> {
  TimeOfDay timeOfDay = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeOfDay.minute != TimeOfDay.now().minute) {
        setState(() {
          timeOfDay = TimeOfDay.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: Text(
          timeOfDay.format(context),
          style: AppStyles.headline4TextStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
