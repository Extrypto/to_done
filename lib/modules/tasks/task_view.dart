import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tasks_bloc.dart';
import 'task_subtasks_list.dart';

class TaskViewPage extends StatefulWidget {
  final String taskId;
  final String userId;
  final String currentFilter;

  TaskViewPage(
      {Key? key,
      required this.taskId,
      required this.userId,
      required this.currentFilter})
      : super(key: key);

  @override
  _TaskViewPageState createState() => _TaskViewPageState();
}

class _TaskViewPageState extends State<TaskViewPage> {
  late TextEditingController _titleController;
  late bool isCompleted;
  late bool isImportant;
  late bool isInMyDay;
  late bool isArchived;
  late bool isDeleted;
  List<Map<String, dynamic>> subtasks = []; // saving subtasks

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleController.addListener(_onTitleChanged);
    _loadTaskData();
    _loadSubtasks();
  }

  void _onTitleChanged() {
    TaskStatusUpdate.updateTaskTitle(
        widget.userId, widget.taskId, _titleController.text);
  }

  Future<void> _loadTaskData() async {
    var taskDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .get();
    var taskData = taskDoc.data();
    setState(() {
      _titleController.text = taskData?['title'] ?? '';
      isCompleted = taskData?['statusDone'] ?? false;
      isImportant = taskData?['statusImportant'] ?? false;
      isInMyDay = taskData?['statusMyDay'] ?? false;
      isArchived = taskData?['statusArchived'] ?? false;
      isDeleted = taskData?['statusDeleted'] ?? false;
    });
  }

  Future<void> _loadSubtasks() async {
    var taskDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .get();
    var taskData = taskDoc.data();
    setState(() {
      subtasks = List<Map<String, dynamic>>.from(taskData?['subtasks'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentFilter),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          // Здесь можно добавить дополнительные действия
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildTaskView(),
      ),
    );
  }

  Widget _buildTaskView() {
    if (_titleController.text.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      // Обеспечивает прокрутку всей страницы
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'What would you like to do?',
                border: InputBorder.none,
              ),
              maxLines:
                  null, // Позволяет тексту занимать неограниченное количество строк
              minLines: 1, // Минимальное количество строк
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.green,
                  ),
                  onPressed: () => _toggleTaskStatus(!isCompleted),
                ),
                IconButton(
                  icon: Icon(
                    isImportant ? Icons.push_pin : Icons.push_pin_outlined,
                    color: Colors.amber,
                  ),
                  onPressed: () => _toggleTaskImportance(),
                ),
                IconButton(
                  icon: Icon(
                    isInMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () => _toggleTaskMyDayStatus(),
                ),
                IconButton(
                  icon: Icon(Icons.archive_outlined, color: Colors.grey),
                  onPressed: () => _archiveTask(),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(),
                ),
              ],
            ),
            TaskSubtasksList(
              taskId: widget.taskId,
              userId: widget.userId,
              taskTitle: _titleController.text,
              subtasks: subtasks,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTaskStatus(bool newStatus) {
    TaskStatusUpdate.toggleTaskStatus(widget.userId, widget.taskId, newStatus)
        .then((_) => setState(() => isCompleted = newStatus));
  }

  void _toggleTaskImportance() {
    TaskStatusUpdate.toggleTaskImportance(
            widget.userId, widget.taskId, !isImportant)
        .then((_) => setState(() => isImportant = !isImportant));
  }

  void _toggleTaskMyDayStatus() {
    TaskStatusUpdate.toggleTaskMyDayStatus(
            widget.userId, widget.taskId, !isInMyDay)
        .then((_) => setState(() => isInMyDay = !isInMyDay));
  }

  void _archiveTask() {
    TaskStatusUpdate.toggleArchiveStatus(
            widget.userId, widget.taskId, !isArchived)
        .then((_) => setState(() => isArchived = !isArchived));
  }

  void _deleteTask() {
    TaskStatusUpdate.toggleDeleteStatus(
            widget.userId, widget.taskId, !isDeleted)
        .then((_) => setState(() => isDeleted = !isDeleted));
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }
}
