import 'package:flutter/widgets.dart';

class AppColors {
  final Color backgroundColor;
  final Color textColor;
  final Color buttonColor;
  final Color cardColor;
  final Color borderColor;
  final Color appBarColor;
  final Color black;
  final Color secondaryTextColor;

  const AppColors({
    required this.backgroundColor,
    required this.textColor,
    required this.buttonColor,
    required this.cardColor,
    required this.borderColor,
    required this.appBarColor,
    required this.black,
    required this.secondaryTextColor,
  });

  static const AppColors dark = AppColors(
    backgroundColor: Color(0xff1e1e1e),
    textColor: Color(0xffffffff),
    buttonColor: Color(0xff007bff),
    cardColor: Color(0xff2c2c2c),
    borderColor: Color(0xff3c3c3c),
    appBarColor: Color(0xff2c2c2c),
    black: Color(0xff121212),
    secondaryTextColor: Color(0xff7a7a7a),
  );

  static const AppColors light = AppColors(
    backgroundColor: Color(0xfff6f5ed),
    textColor: Color(0xff121212),
    buttonColor: Color(0xff007bff),
    cardColor: Color(0xffffffff),
    borderColor: Color(0xffe0e0e0),
    appBarColor: Color(0xffffffff),
    black: Color(0xff121212),
    secondaryTextColor: Color(0xff7a7a7a),
  );
}

//  final themeMode = ref.watch(themeProvider);
//     final isDark =
//         themeMode == ThemeMode.dark ||
//         (themeMode == ThemeMode.system &&
//             MediaQuery.platformBrightnessOf(context) == Brightness.dark);
//     final colors = isDark ? AppColors.dark : AppColors.light;
