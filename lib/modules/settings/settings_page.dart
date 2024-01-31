import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_done/modules/core/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_done/modules/auth/login_or_register.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              //theme switcher //
              SwitchListTile(
                title: const Text("Dark Mode"),
                onChanged: (_) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Icon(Icons.check);
                    }
                    return const Icon(Icons
                        .close); // All other states will use the default thumbIcon.
                  },
                ),
                activeColor: Colors.white,
                activeTrackColor: Colors.blue,
              ),
              //theme switch //
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Account settings'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Sounds & Notifications'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),
              ListTile(
                leading: const Icon(Icons.format_paint_outlined),
                title: const Text('General'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date & Time'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Documentation'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),

              ListTile(
                leading: const Icon(Icons.local_cafe_outlined),
                title: const Text('Support Project'),
                onTap: () {/* Навигация на соответствующую страницу */},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                onTap: () async {
                  // Выход из аккаунта гугл с очисткой кэша. перенести потом в сервис. должна быть логика для обработки выхода из файрбейс и гугл
                  // должна быть опция удаления аккаунта. согласно(?) политике гугл
                  //это должно быть вынесено в bloc и дёргаться оттуда. здесь не должно быть логики, только UI!
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginOrRegister(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    print("Ошибка при выходе из аккаунта: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
