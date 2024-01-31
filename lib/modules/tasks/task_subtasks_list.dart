import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'task_update.dart'; // Убедитесь, что task_update.dart содержит необходимые функции

class TaskSubtasksList extends StatefulWidget {
  final String taskId;
  final String userId; // Добавлено для передачи заголовка задачи
  final List<Map<String, dynamic>> subtasks;

  const TaskSubtasksList({
    Key? key,
    required this.taskId,
    required this.userId,
    required this.subtasks,
    required String taskTitle,
  }) : super(key: key);

  @override
  _TaskSubtasksListState createState() => _TaskSubtasksListState();
}

class _TaskSubtasksListState extends State<TaskSubtasksList> {
  late TextEditingController _subtaskController;

  @override
  void initState() {
    super.initState();
    _subtaskController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _subtaskController,
          decoration: InputDecoration(
            labelText: 'Новая субзадача',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _addSubtask(_subtaskController.text);
                _subtaskController.clear();
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        IconButton(
          icon: Icon(Icons.auto_awesome_outlined),
          onPressed: () {},
        ),
        widget.subtasks.isEmpty
            ? Center(child: Text('Нет субзадач'))
            : ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.subtasks.length,
                itemBuilder: (context, index) {
                  var subtask = widget.subtasks[index];
                  return ListTile(
                    key: ValueKey(subtask),
                    leading: Icon(subtask['completed']
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onTap: () =>
                        _toggleSubtaskStatus(index, !subtask['completed']),
                    title: Text(subtask['title']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSubtask(index),
                    ),
                  );
                },
                onReorder: _onReorder,
              ),
      ],
    );
  }

  void _addSubtask(String title) {
    if (title.trim().isEmpty) return;

    var newSubtask = {
      'title': title,
      'completed': false,
      'index': widget.subtasks.length
    };

    setState(() {
      widget.subtasks.add(newSubtask);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'subtasks': FieldValue.arrayUnion([newSubtask])
    });
  }

  void _toggleSubtaskStatus(int index, bool newStatus) {
    setState(() {
      widget.subtasks[index]['completed'] = newStatus;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'subtasks': widget.subtasks,
    });
  }

  void _deleteSubtask(int index) {
    var subtaskToDelete = widget.subtasks[index];
    setState(() {
      widget.subtasks.removeAt(index);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'subtasks': FieldValue.arrayRemove([subtaskToDelete])
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var subtask = widget.subtasks.removeAt(oldIndex);
    widget.subtasks.insert(newIndex, subtask);

    for (int i = 0; i < widget.subtasks.length; i++) {
      widget.subtasks[i]['index'] = i;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'subtasks': widget.subtasks,
    });
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }
}
