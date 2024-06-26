import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:to_done/modules/tasks/task_view.dart';

class TaskListWidget extends StatelessWidget {
  final String userId;
  final String sortCriteria; // Параметр для управления критериями сортировки

  const TaskListWidget({
    Key? key,
    required this.userId,
    this.sortCriteria = 'date', // Значение по умолчанию для сортировки
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        String currentFilter = 'All';
        if (state is TasksFilterUpdatedState) {
          currentFilter = state.currentFilter;
        }
        return _buildTaskList(currentFilter, userId,
            sortCriteria); // Добавляем параметр сортировки
      },
    );
  }

  Widget _buildTaskList(
      String statusFilter, String userId, String sortCriteria) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildTaskQuery(statusFilter, userId, sortCriteria),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print('Ошибка: ${snapshot.error}');
          return Text('Ошибка: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final tasks = snapshot.data!.docs;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isImportant = task['statusImportant'] ?? false;
            final isInMyDay = task['statusMyDay'] ?? false;
            final isCompleted = task['statusDone'] ?? false;
            final priority = task['priority'] ?? 0;

            Color circleColor;
            switch (priority) {
              case 1:
                circleColor = Colors.blue;
                break;
              case 2:
                circleColor = Colors.orange;
                break;
              case 3:
                circleColor = Colors.red;
                break;
              default:
                circleColor = Colors.grey;
            }

            return Dismissible(
              key: Key(task.id),
              background: Container(
                color: Colors.grey,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 50.0),
                child: const Icon(Icons.archive_outlined, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 50.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                _handleDismiss(context, direction, task.id);
              },
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_outlined
                        : Icons.circle_outlined,
                    color: circleColor, // цвет в зависимости от приоритета
                  ),
                  onPressed: () {
                    _toggleTaskStatus(task.id, !isCompleted);
                  },
                ),
                title: Text(
                  task['title'],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskViewPage(
                        taskId: task.id,
                        userId: userId,
                        currentFilter: statusFilter,
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isInMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                        color: isInMyDay ? Colors.blue : null,
                      ),
                      onPressed: () {
                        _toggleTaskMyDayStatus(task.id, !isInMyDay);
                      },
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     isImportant ? Icons.push_pin : Icons.push_pin_outlined,
                    //     color: isImportant ? Colors.amber : null,
                    //   ),
                    //   onPressed: () {
                    //     _toggleTaskImportance(task.id, !isImportant);
                    //   },
                    // ),
                  ],
                ),
                visualDensity: VisualDensity(horizontal: -4.0),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildTaskQuery(
      String statusFilter, String userId, String sortCriteria) {
    // Измените тип переменной на Query
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    // Применение сортировки в зависимости от выбранного критерия
    switch (sortCriteria) {
      case 'name':
        query = query.orderBy('title', descending: false);
        break;
      case 'priority':
        query = query.orderBy('priority', descending: true);
        break;
      case 'date':
      default:
        query = query.orderBy('creationDate', descending: true);
        break;
    }

    // Применение фильтров в зависимости от текущего фильтра статуса
    switch (statusFilter) {
      case 'All':
        query = query
            .where('statusDone', isEqualTo: false)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false);
        break;
      case 'Inbox':
        query = query
            .where('statusDone', isEqualTo: false)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .where('listId', isEqualTo: 'Inbox');
        break;
      case 'Completed':
        query = query
            .where('statusDone', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false);
        break;
      case 'Archive':
        query = query
            .where('statusArchived', isEqualTo: true)
            .where('statusDeleted', isEqualTo: false);
        break;
      case 'Trash':
        query = query.where('statusDeleted', isEqualTo: true);
        break;
      case 'Important':
        query = query
            .where('statusImportant', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false);
        break;
      case 'MyDay':
        query = query
            .where('statusMyDay', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false);
        break;
      default:
        query = query.where('listId', isEqualTo: statusFilter);
        break;
    }

    return query.snapshots();
  }

  void _toggleTaskStatus(String taskId, bool newStatus) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusDone': newStatus});
  }

  void _toggleTaskImportance(String taskId, bool newStatus) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusImportant': newStatus});
  }

  void _toggleTaskMyDayStatus(String taskId, bool newStatus) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusMyDay': newStatus});
  }

  void _handleDismiss(
      BuildContext context, DismissDirection direction, String taskId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .get()
        .then((taskDoc) {
      var taskData = taskDoc.data();
      bool isDeleted = taskData?['statusDeleted'] ?? false;
      bool isArchived = taskData?['statusArchived'] ?? false;

      if (direction == DismissDirection.endToStart) {
        // Если задача архивирована, сначала снимаем статус архива
        if (isArchived) {
          TaskStatusUpdate.toggleArchiveStatus(userId, taskId, false);
        }
        TaskStatusUpdate.toggleDeleteStatus(userId, taskId, !isDeleted);
      } else if (direction == DismissDirection.startToEnd) {
        // Если задача в корзине, сначала снимаем статус удаления
        if (isDeleted) {
          TaskStatusUpdate.toggleDeleteStatus(userId, taskId, false);
        }
        TaskStatusUpdate.toggleArchiveStatus(userId, taskId, !isArchived);
      }
    });
  }
}
