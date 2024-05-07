import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Определение событий
abstract class TasksEvent {}

class OpenBottomSheetEvent extends TasksEvent {}

class AddTaskFromBottomSheetEvent extends TasksEvent {
  final String userId;
  final String title;
  final DateTime creationDate;
  final bool statusDone;
  final bool statusMyDay;
  final bool statusImportant;
  final bool statusArchive;
  final bool statusDeleted;
  final String listId;
  final int priority; // Добавлено: приоритет задачи

  AddTaskFromBottomSheetEvent({
    required this.userId,
    required this.title,
    DateTime? creationDate,
    this.statusDone = false,
    this.statusMyDay = false,
    this.statusImportant = false,
    this.statusArchive = false,
    this.statusDeleted = false,
    this.listId = "Inbox",
    this.priority = 0, // Добавлено: значение по умолчанию для приоритета
  }) : creationDate = creationDate ?? DateTime.now();
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
        // Отправка задачи в Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(event.userId)
            .collection('tasks')
            .add({
          'title': event.title,
          'creationDate': event.creationDate.toIso8601String(),
          'statusDone': event.statusDone,
          'statusMyDay': event.statusMyDay,
          'statusImportant': event.statusImportant,
          'statusArchived': event.statusArchive,
          'statusDeleted': event.statusDeleted,
          'listId': event.listId,
          'priority': event.priority
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

class TaskStatusUpdate {
  static Future<void> toggleTaskStatus(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusDone': newStatus});
    } catch (error) {
      print('Error toggling task status: $error');
    }
  }

  static Future<void> toggleTaskImportance(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusImportant': newStatus});
    } catch (error) {
      print('Error toggling task importance: $error');
    }
  }

  static Future<void> toggleTaskMyDayStatus(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusMyDay': newStatus});
    } catch (error) {
      print('Error toggling task MyDay status: $error');
    }
  }

  static Future<void> toggleArchiveStatus(
      String userId, String taskId, bool newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusArchived': newStatus});
  }

  static Future<void> toggleDeleteStatus(
      String userId, String taskId, bool newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusDeleted': newStatus});
  }

  static Future<void> updateTaskTitle(
      String userId, String taskId, String title) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'title': title});
  }
}
