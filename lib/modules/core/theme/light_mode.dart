import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // Убираем закругление углов
    ),
  ),
  colorScheme: ColorScheme.light(),
);
