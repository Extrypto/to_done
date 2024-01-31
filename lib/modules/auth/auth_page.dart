import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/pages/home_page.dart';
import 'package:to_done/modules/auth/login_or_register.dart';
import 'package:to_done/modules/auth/user_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBloc = context.read<UserBloc>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Пользователь залогинен
          userBloc.add(UserLoggedIn(userId: snapshot.data!.uid));
          return HomePage();
        } else {
          // Пользователь не залогинен
          userBloc.add(UserLoggedOut());
          return const LoginOrRegister();
        }
      },
    );
  }
}
