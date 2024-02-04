import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/pages/home_page.dart';
import 'package:to_done/modules/auth/login_or_register.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final userBloc = context.read<UserBloc>();
          if (snapshot.hasData && snapshot.data != null) {
            // Пользователь залогинен
            userBloc.add(UserLoggedIn(userId: snapshot.data!.uid));
            _navigateWithAnimation(context, HomePage());
          } else {
            // Пользователь не залогинен
            userBloc.add(UserLoggedOut());
            _navigateWithAnimation(context, LoginOrRegister());
          }
        }
        // Пока соединение активно, показываем сплэш-скрин
        return const Scaffold(
          body: Center(
            child: Icon(
              Icons.check_circle,
              size: 150,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
        );
      },
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget page) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Задержка для сплеш-скрина

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        // Использование CurvedAnimation с более плавной кривой
        return FadeTransition(
          opacity: fadeTween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic, // Изменение кривой на более плавную
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(
          milliseconds:
              999), // Увеличение времени анимации для большей плавности
    ));
  }
}
