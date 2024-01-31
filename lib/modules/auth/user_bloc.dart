import 'package:flutter_bloc/flutter_bloc.dart';

// Определение событий
abstract class UserEvent {}

class UserLoggedIn extends UserEvent {
  final String userId;

  UserLoggedIn({required this.userId});
}

class UserLoggedOut extends UserEvent {}

// Определение состояний
abstract class UserState {}

class UserInitial extends UserState {}

class UserAuthenticated extends UserState {
  final String userId;

  UserAuthenticated({required this.userId});
}

class UserUnauthenticated extends UserState {}

// Определение Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    // Обработчик для события UserLoggedIn
    on<UserLoggedIn>((event, emit) {
      emit(UserAuthenticated(userId: event.userId));
    });

    // Обработчик для события UserLoggedOut
    on<UserLoggedOut>((event, emit) {
      emit(UserUnauthenticated());
    });
  }
}
// В этом коде:

// UserEvent определяет базовый класс для событий, с производными классами UserLoggedIn и UserLoggedOut.
// UserState определяет базовый класс для состояний, с производными классами UserInitial, UserAuthenticated и UserUnauthenticated.
// UserBloc является Bloc, который обрабатывает события UserLoggedIn и UserLoggedOut и производит соответствующие состояния.
// Убедитесь, что у вас установлена последняя версия пакета flutter_bloc, чтобы использовать этот новый синтаксис.