import 'package:to_done/modules/tasks/home_page.dart';
import 'package:to_done/modules/auth/splash_screen.dart';
import 'package:to_done/modules/tasks/list/list_add_screen.dart';
import 'package:to_done/modules/settings/settings_page.dart';
import 'package:to_done/modules/search/search_page.dart';

final routes = {
  '/': (context) => SplashScreen(),
  '/home': (context) => HomePage(),
  '/settings': (context) => SettingsPage(),
  '/add_list': (context) => AddListScreen(),
  '/search': (context) => SearchPage(),
};
