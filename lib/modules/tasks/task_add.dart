import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add this import for FontAwesome icons

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
  List<PopupMenuItem<String>> listItems = []; // Popup items for lists

  final List<PopupMenuItem<int>> priorityItems = [
    const PopupMenuItem(value: 0, child: Text("No Priority")),
    const PopupMenuItem(value: 1, child: Text("Low Priority")),
    const PopupMenuItem(value: 2, child: Text("Medium Priority")),
    const PopupMenuItem(value: 3, child: Text("High Priority")),
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
        .map((doc) => PopupMenuItem<String>(
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
          PopupMenuItem<String>(
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
              TextField(
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PopupMenuButton<int>(
                    icon: FaIcon(FontAwesomeIcons.flag),
                    onSelected: (int newValue) {
                      setState(() {
                        selectedPriority = newValue;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return priorityItems;
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: FaIcon(FontAwesomeIcons.list),
                    onSelected: (String newValue) {
                      setState(() {
                        selectedListId = newValue;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return listItems;
                    },
                  ),
                  // IconButton(
                  //   icon: FaIcon(FontAwesomeIcons.calendar),
                  //   onPressed: () {
                  //     // Add your onPressed code here
                  //   },
                  // ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.ellipsisH),
                    onPressed: () {
                      // Add your onPressed code here
                    },
                  ),
                  // IconButton(
                  //   icon: FaIcon(FontAwesomeIcons.expand),
                  //   onPressed: () {
                  //     // Add your onPressed code here
                  //   },
                  // ),
                  Spacer(), // This will push the send button to the right
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
                      width: 60.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0),
                        color: isButtonBlue ? Colors.blue : Colors.grey,
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
            ],
          ),
        ),
      ),
    );
  }
}
