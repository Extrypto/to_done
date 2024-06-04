import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tasks_bloc.dart';
import 'task_subtasks_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  bool isCompleted = false;
  bool isImportant = false;
  bool isInMyDay = false;
  bool isArchived = false;
  bool isDeleted = false;
  int priority = 0; // Начальный приоритет задачи

  List<Map<String, dynamic>> subtasks = [];

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
      priority = taskData?['priority'] ?? 0; // Загрузка приоритета задачи
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
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: <Widget>[
          // Добавляем действия в AppBar
          PopupMenuButton<String>(
            onSelected: (String result) {
              // Вы можете обработать выбор здесь
              switch (result) {
                case 'Settings':
                  break;
                case 'Logout':
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Empty'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Empty'),
              ),
              // Добавьте другие элементы меню здесь
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildTaskView(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        height: AppBar().preferredSize.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: FaIcon(priority == 0
                  ? FontAwesomeIcons.flag
                  : FontAwesomeIcons.solidFlag),
              color: _priorityColor(priority),
              onPressed: () => _changePriority(),
            ),
            IconButton(
              icon:
                  Icon(isImportant ? Icons.push_pin : Icons.push_pin_outlined),
              color: Colors.amber,
              onPressed: () => _toggleTaskImportance(),
            ),
            IconButton(
              icon: Icon(isInMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined),
              color: Colors.blue,
              onPressed: () => _toggleTaskMyDayStatus(),
            ),
            IconButton(
              icon: Icon(isArchived ? Icons.archive : Icons.archive_outlined),
              color: Colors.grey,
              onPressed: () => _archiveTask(),
            ),
            IconButton(
              icon: Icon(isDeleted ? Icons.delete : Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _deleteTask(),
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
      ),
    );
  }

  Widget _buildTaskView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Выравнивание по центру
              children: [
                IconButton(
                  icon: Icon(isCompleted
                      ? Icons.check_circle_outline_outlined
                      : Icons.circle_outlined),
                  color: Colors.grey,
                  onPressed: () => _toggleTaskStatus(!isCompleted),
                ),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'What would you like to be done?',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TaskSubtasksList(
                taskId: widget.taskId,
                userId: widget.userId,
                taskTitle: _titleController.text,
                subtasks: subtasks),
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

  void _changePriority() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriorityItem(0, 'No Priority', Colors.grey),
              _buildPriorityItem(1, 'Low Priority', Colors.blue),
              _buildPriorityItem(2, 'Medium Priority', Colors.orange),
              _buildPriorityItem(3, 'High Priority', Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityItem(int value, String text, Color color) {
    return ListTile(
      leading: FaIcon(
          value == 0 ? FontAwesomeIcons.flag : FontAwesomeIcons.solidFlag,
          color: color),
      title: Text(text),
      trailing:
          priority == value ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('tasks')
            .doc(widget.taskId)
            .update({'priority': value}).then((_) {
          Navigator.pop(context);
          setState(() {
            priority = value;
          });
        });
      },
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }
}
