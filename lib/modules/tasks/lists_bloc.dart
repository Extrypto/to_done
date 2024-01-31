import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Определение событий
abstract class ListsEvent {}

class CreateListEvent extends ListsEvent {
  final String userId;
  final String title;

  CreateListEvent(this.userId, this.title);
}

class UpdateListEvent extends ListsEvent {
  final String listId;
  final String newTitle;

  UpdateListEvent(this.listId, this.newTitle);
}

class DeleteListEvent extends ListsEvent {
  final String listId;

  DeleteListEvent(this.listId);
}

// Определение состояний
abstract class ListsState {}

class ListCreatedState extends ListsState {}

class ListUpdatedState extends ListsState {}

class ListDeletedState extends ListsState {}

class ListErrorState extends ListsState {
  final String message;

  ListErrorState(this.message);
}

// BLoC для листов
class ListsBloc extends Bloc<ListsEvent, ListsState> {
  ListsBloc() : super(ListCreatedState()) {
    on<CreateListEvent>((event, emit) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(event.userId)
            .collection('lists')
            .add({
          'title': event.title,
          'creationDate': DateTime.now(),
          'icon': Icons.list_rounded.toString(),
          'color': 'none',
        });
        emit(ListCreatedState());
      } catch (e) {
        emit(ListErrorState('Ошибка при создании листа: $e'));
      }
    });

    // Добавьте обработчики для UpdateListEvent и DeleteListEvent
  }
}
