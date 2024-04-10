import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool isButtonBlue = false; // Объявление переменной здесь

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
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _addTaskToFirestore(BuildContext context,
      {required String userId, required String title}) {
    if (title.isNotEmpty) {
      BlocProvider.of<TasksBloc>(context).add(AddTaskFromBottomSheetEvent(
        userId: userId,
        title: title,
      ));
      titleController.clear();
      FocusScope.of(context).requestFocus(focusNode); // Return focus on input
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title')),
      );
    }
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) => _addTaskToFirestore(
                        context,
                        userId: (BlocProvider.of<UserBloc>(context).state
                                as UserAuthenticated)
                            .userId,
                        title: value.trim(),
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
            ],
          ),
        ),
      ),
    );
  }
}
