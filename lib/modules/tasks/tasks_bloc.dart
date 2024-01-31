import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Определение событий
abstract class TasksEvent {}

class OpenBottomSheetEvent extends TasksEvent {}

class AddTaskFromBottomSheetEvent extends TasksEvent {
  final String userId;
  final String title;
  late DateTime
      creationDate; // Используем late для объявления неинициализированного поля
  final bool statusDone;
  final bool statusMyDay;
  final bool statusImportant;
  final bool statusArchive;
  final bool statusDeleted;
  final String listId;

  AddTaskFromBottomSheetEvent({
    required this.userId,
    required this.title,
    DateTime? creationDate, // Опциональный параметр
    this.statusDone = false,
    this.statusMyDay = false,
    this.statusImportant = false,
    this.statusArchive = false,
    this.statusDeleted = false,
    this.listId = "Inbox",
  }) {
    this.creationDate = creationDate ?? DateTime.now(); // Инициализация поля
  }
}

class UpdateTaskFilterEvent extends TasksEvent {
  final String newFilter;

  UpdateTaskFilterEvent(this.newFilter);
}

// Определение состояний
abstract class TasksState {
  final String currentFilter;

  TasksState({this.currentFilter = 'All'});
}

class TaskAddedState extends TasksState {}

class TaskErrorState extends TasksState {
  final String message;

  TaskErrorState({required this.message});
}

class BottomSheetClosedState extends TasksState {}

class TasksFilterUpdatedState extends TasksState {
  TasksFilterUpdatedState(String newFilter) : super(currentFilter: newFilter);
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc() : super(BottomSheetClosedState()) {
    on<OpenBottomSheetEvent>((event, emit) {});

    on<AddTaskFromBottomSheetEvent>((event, emit) async {
      try {
        // Отправка данных в Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(event.userId)
            .collection('tasks')
            .add({
          'title': event.title,
          'creationDate': event.creationDate,
          'statusDone': event.statusDone,
          'statusMyDay': event.statusMyDay, // Добавлено
          'statusImportant': event.statusImportant, // Добавлено
          'statusArchived': event.statusArchive,
          'statusDeleted': event.statusDeleted,
          'listId': event.listId,
        });

        emit(TaskAddedState());
      } catch (e) {
        emit(TaskErrorState(message: 'Ошибка при добавлении задачи: $e'));
      }
    });

    on<UpdateTaskFilterEvent>((event, emit) {
      emit(TasksFilterUpdatedState(event.newFilter));
    });
  }
}
