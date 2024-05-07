import 'package:to_done/pages/home_page.dart';
import 'package:to_done/modules/auth/splash_screen.dart';
import 'package:to_done/modules/tasks/list/list_add_screen.dart';
import 'package:to_done/pages/settings_page.dart';

final routes = {
  '/': (context) => SplashScreen(),
  '/home': (context) => HomePage(),
  '/settings': (context) => SettingsPage(),
  '/add_list': (context) => AddListScreen(),
};
