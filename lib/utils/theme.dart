import 'package:flutter/material.dart';
import 'package:pan_tv/utils/styles.dart';

class MyTheme {
  static ThemeData myTheme = ThemeData(
      fontFamily: "helvetica",
      scaffoldBackgroundColor: Styles.primaryBlack,
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Styles.secondaryColor));
}
