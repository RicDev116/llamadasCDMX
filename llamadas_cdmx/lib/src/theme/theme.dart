import 'package:flutter/material.dart';

ThemeData companyThemeData = new ThemeData(
    appBarTheme: new AppBarTheme(),
    brightness: Brightness.light,
    fontFamily: 'Montserrat',

    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold, color: Color(0xff00D1A3)),
      headline2: TextStyle(fontSize: 60.0, fontWeight: FontWeight.w100),
      headline3: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText1: TextStyle(fontSize: 18.0, fontFamily: 'Hind'),
      bodyText2: TextStyle(fontSize: 10.0, fontFamily: 'Hind'),
    ),

    primarySwatch:MaterialColor(ColorAplicacion.blue[50].value, ColorAplicacion.blue),
    primaryColor: ColorAplicacion.blue[500],
    primaryColorBrightness: Brightness.light,
    accentColor: ColorAplicacion.green[300],
    accentColorBrightness: Brightness.light);

    

class ColorAplicacion {
  ColorAplicacion._(); // this basically makes it so you can instantiate this class
  static const Map<int, Color> blue = const <int, Color>{
    50: const Color(0xff00BDD4),
    100: const Color(0xff08AEBA),
    200: const Color(0xff049296),
    300: const Color(0xff05937B),
    400: const Color(0xff037A63),
    500: const Color(0xff08aeba),
    600: const Color(0xff0485a3),
    700: const Color(0xff136d89),
    800: const Color(0xff17576b),
    900: const Color(0xff174351)
  };

  static const Map<int, Color> green = const <int, Color>{
    50: const Color(0xff62D600),
    100: const Color(0xff09CEA8),
    200: const Color(0xff0BB796),
    300: const Color(0xff079378),
    400: const Color(0xff067F68),
    500: const Color(0xff0D6353),
    600: const Color(0xff0C4F42),
    700: const Color(0xff053A30),
    800: const Color(0xff032D25),
    900: const Color(0xff02231D)
  };
}
