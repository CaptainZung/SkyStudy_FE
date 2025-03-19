import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Color.fromARGB(255, 200, 229, 235),
    textTheme: TextTheme(
      headlineSmall: TextStyle(color: Colors.blue, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: TextStyle(fontSize: 16),
      ),
    ),
  );
}