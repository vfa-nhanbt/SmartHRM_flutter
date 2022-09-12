import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/dimens.dart';
import 'config/routes.dart';
import 'config/themes.dart';

class SmartHRMApp extends StatelessWidget {
  const SmartHRMApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppDimens.appDesignSize,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        // supportedLocales: L10n.all,
        theme: ThemeData(
          textTheme: AppThemes.appTextTheme,
          colorScheme: AppThemes.appColorSchema,
        ),
        onGenerateRoute: (settings) => AppRoutes().onGenerateRoute(settings),
        initialRoute: AppRoutes.init,
      ),
    );
  }
}
