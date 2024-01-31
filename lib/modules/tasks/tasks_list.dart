import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:to_done/modules/tasks/task_view.dart';

class TaskListWidget extends StatelessWidget {
  final String userId;

  const TaskListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is TasksFilterUpdatedState) {
          return _buildTaskList(state.currentFilter, userId);
        } else {
          return _buildTaskList(
              'All', userId); // Или другое значение по умолчанию для фильтра
        }
      },
    );
  }

  Widget _buildTaskList(String statusFilter, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildTaskQuery(statusFilter, userId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
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
            final isCompleted = task['statusDone'] ?? false;
            final isImportant = task['statusImportant'] ?? false;
            final isInMyDay = task['statusMyDay'] ?? false;

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
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
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
                        userId:
                            userId, // Предполагается, что userId доступен в этом контексте
                        currentFilter:
                            statusFilter, // Передача текущего фильтра
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
                    IconButton(
                      icon: Icon(
                        isImportant ? Icons.star : Icons.star_border,
                        color: isImportant ? Colors.amber : null,
                      ),
                      onPressed: () {
                        _toggleTaskImportance(task.id, !isImportant);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildTaskQuery(String statusFilter, String userId) {
    var query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    switch (statusFilter) {
      case 'All':
        return query
            .where('statusDone', isEqualTo: false)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .snapshots();
      case 'Inbox':
        return query
            .where('statusDone', isEqualTo: false)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .where('listId', isEqualTo: 'Inbox')
            .snapshots();
      case 'Completed':
        return query
            .where('statusDone', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .snapshots();
      case 'Archive':
        return query
            .where('statusArchived', isEqualTo: true)
            .where('statusDeleted', isEqualTo: false)
            .snapshots();
      case 'Trash':
        return query.where('statusDeleted', isEqualTo: true).snapshots();
      case 'Important':
        return query
            .where('statusImportant', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .snapshots();
      case 'MyDay':
        return query
            .where('statusMyDay', isEqualTo: true)
            .where('statusArchived', isEqualTo: false)
            .where('statusDeleted', isEqualTo: false)
            .snapshots();

      default:
        return query.snapshots();
    }
  }

  void _toggleTaskStatus(String taskId, bool newStatus) {
    TaskStatusUpdate.toggleTaskStatus(userId, taskId, newStatus);
  }

  void _toggleTaskImportance(String taskId, bool newStatus) {
    TaskStatusUpdate.toggleTaskImportance(userId, taskId, newStatus);
  }

  void _toggleTaskMyDayStatus(String taskId, bool newStatus) {
    TaskStatusUpdate.toggleTaskMyDayStatus(userId, taskId, newStatus);
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
