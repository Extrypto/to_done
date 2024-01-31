import 'package:flutter/material.dart';

// ThemeData darkMode = ThemeData.dark().copyWith(
//   colorScheme: ColorScheme.dark(
//     background: const Color.fromARGB(255, 20, 20, 20),
//     primary: const Color.fromARGB(255, 105, 105, 105),
//     secondary: const Color.fromARGB(255, 30, 30, 30),
//     tertiary: const Color.fromARGB(255, 47, 47, 47),
//     inversePrimary: Colors.grey.shade300,
//   ),
// );

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // Убираем закругление углов
    ),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    // ···
    brightness: Brightness.dark,
  ),
);
