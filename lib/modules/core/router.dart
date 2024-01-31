import 'package:to_done/pages/home_page.dart';
import 'package:to_done/modules/auth/splash_screen.dart';
import 'package:to_done/modules/tasks/list_add_screen.dart';
import 'package:to_done/modules/settings/settings_page.dart';
import 'package:to_done/modules/core/firebase_admin/dashboard.dart';

final routes = {
  '/': (context) => SplashScreen(),
  '/home': (context) => HomePage(),
  '/settings': (context) => SettingsPage(),
  '/dashboard': (context) => FirebaseDashboard(),
  '/add_list': (context) => AddListScreen(),
};
