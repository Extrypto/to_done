import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';

class TasksAddBottomSheet extends StatefulWidget {
  const TasksAddBottomSheet({Key? key}) : super(key: key);

  @override
  State<TasksAddBottomSheet> createState() => _TasksAddBottomSheetState();
}

class _TasksAddBottomSheetState extends State<TasksAddBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isButtonBlue = false;
  int selectedPriority = 0; // Default to "No Priority"
  String? selectedListId; // Variable to hold the selected list id
  List<DropdownMenuItem<String>> listItems = []; // Dropdown items for lists

  final List<DropdownMenuItem<int>> priorityItems = [
    const DropdownMenuItem(value: 0, child: Text("No Priority")),
    const DropdownMenuItem(value: 1, child: Text("Low Priority")),
    const DropdownMenuItem(value: 2, child: Text("Medium Priority")),
    const DropdownMenuItem(value: 3, child: Text("High Priority")),
  ];

  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      if (titleController.text.isNotEmpty != isButtonBlue) {
        setState(() {
          isButtonBlue = titleController.text.isNotEmpty;
        });
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
      _loadLists();
    });
  }

  Future<void> _loadLists() async {
    String userId =
        (BlocProvider.of<UserBloc>(context).state as UserAuthenticated).userId;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .get();

    var items = snapshot.docs
        .map((doc) => DropdownMenuItem<String>(
              value: doc.id,
              child: Text(doc.data()['title'] ?? 'Unnamed List'),
            ))
        .toList();

    // Проверяем, есть ли Inbox среди загруженных списков
    bool hasInbox = items.any((item) => item.value == "Inbox");
    if (!hasInbox) {
      // Добавляем Inbox, если его нет
      items.insert(
          0,
          DropdownMenuItem<String>(
            value: "Inbox",
            child: Text("Inbox"),
          ));
    }

    setState(() {
      listItems = items;
      // Устанавливаем Inbox по умолчанию
      selectedListId = items
          .firstWhere((item) => item.value == "Inbox",
              orElse: () => items.first)
          .value;
    });
  }

  void _addTaskToFirestore(BuildContext context,
      {required String userId,
      required String title,
      required int priority,
      String? listId}) {
    if (title.isNotEmpty) {
      BlocProvider.of<TasksBloc>(context).add(AddTaskFromBottomSheetEvent(
        userId: userId,
        title: title,
        priority: priority,
        listId: listId ?? 'Inbox', // Default listId if not specified
      ));
      titleController.clear(); // Очистка поля ввода после отправки
      FocusScope.of(context)
          .requestFocus(focusNode); // Возвращение фокуса на поле ввода
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title')),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15.0,
            right: 15.0,
            top: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Do something awesome...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) => _addTaskToFirestore(
                        context,
                        userId: (BlocProvider.of<UserBloc>(context).state
                                as UserAuthenticated)
                            .userId,
                        title: value.trim(),
                        priority: selectedPriority,
                        listId: selectedListId,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _addTaskToFirestore(
                      context,
                      userId: (BlocProvider.of<UserBloc>(context).state
                              as UserAuthenticated)
                          .userId,
                      title: titleController.text.trim(),
                      priority: selectedPriority,
                      listId: selectedListId,
                    ),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: isButtonBlue ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Task Priority',
                  border: OutlineInputBorder(),
                ),
                value: selectedPriority,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedPriority = newValue ?? 0;
                  });
                },
                items: priorityItems,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select List',
                  border: OutlineInputBorder(),
                ),
                value: selectedListId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedListId = newValue;
                  });
                },
                items: listItems,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
