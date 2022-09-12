import 'package:flutter/material.dart';

import 'colors.dart';
import 'styles.dart';

class AppThemes {
  AppThemes._internal();

  static final TextTheme appTextTheme = TextTheme(
    headline1: AppStyles.headline1TextStyle,
    headline2: AppStyles.headline2TextStyle,
    headline3: AppStyles.headline3TextStyle,
    headline4: AppStyles.headline4TextStyle,
    headline5: AppStyles.headline5TextStyle,
    headline6: AppStyles.headline6TextStyle,
    subtitle1: AppStyles.subtitle1TextStyle,
    subtitle2: AppStyles.subtitle2TextStyle,
    bodyText1: AppStyles.headline5TextStyle,
    bodyText2: AppStyles.headline6TextStyle,
    button: AppStyles.subtitle1TextStyle,
  );

  static final ColorScheme appColorSchema = ThemeData().colorScheme.copyWith(
        primary: AppColors.blackColor,
        secondary: AppColors.secondaryColor,
      );
}
