import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:to_done/modules/tasks/ai_subtask_creator.dart';

class TaskSubtasksList extends StatefulWidget {
  final String taskId;
  final String userId; // Добавлено для передачи заголовка задачи
  final List<Map<String, dynamic>> subtasks;
  final String taskTitle; // Добавляем свойство taskTitle

  const TaskSubtasksList({
    Key? key,
    required this.taskId,
    required this.userId,
    required this.subtasks,
    required this.taskTitle, // Добавляем свойство taskTitle
  }) : super(key: key);

  @override
  _TaskSubtasksListState createState() => _TaskSubtasksListState();
}

class _TaskSubtasksListState extends State<TaskSubtasksList> {
  late TextEditingController _subtaskController;
  late FocusNode _focusNode; // Добавлено для управления фокусом

  @override
  void initState() {
    super.initState();
    _subtaskController = TextEditingController();
    _focusNode = FocusNode(); // Инициализация FocusNode
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _focusNode.dispose(); // Очистка ресурса FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _subtaskController,
          focusNode:
              _focusNode, // Использование FocusNode для управления фокусом
          decoration: InputDecoration(
            labelText: 'Add subtask',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _addSubtask(_subtaskController.text);
                _subtaskController.clear();
                _focusNode.requestFocus(); // Установка фокуса на поле ввода
              },
            ),
          ),
          onSubmitted: (value) {
            _addSubtask(value);
            _subtaskController.clear();
            _focusNode.requestFocus(); // Установка фокуса на поле ввода
          },
        ),
        SizedBox(height: 10),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.wandMagicSparkles),
          onPressed: () async {
            // Получаем список подзадач с помощью AI
            List<String> subtasks =
                await AISubtaskCreator.createSubtasks(widget.taskTitle);

            // Создаём список новых подзадач для добавления в Firestore
            List<Map<String, dynamic>> newSubtasks = subtasks.map((title) {
              return {
                'title': title,
                'completed': false,
                'index': widget.subtasks.length + subtasks.indexOf(title)
              };
            }).toList();

            // Добавление новых подзадач в Firestore одной операцией
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('tasks')
                .doc(widget.taskId)
                .update({'subtasks': FieldValue.arrayUnion(newSubtasks)}).then(
                    (_) {
              // Обновляем локальный UI после успешного добавления в Firestore
              setState(() {
                widget.subtasks.addAll(newSubtasks);
              });
            });
          },
          tooltip: 'Create subtasks with AI',
        ),
        widget.subtasks.isEmpty
            ? Center(child: Text('No subtasks'))
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
                    visualDensity: VisualDensity(horizontal: -4.0),
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
}
