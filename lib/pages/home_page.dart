import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_list.dart';
import 'package:to_done/modules/tasks/tasks_drawer.dart';
import 'package:to_done/modules/tasks/tasks_list_appbar.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/task_add.dart';

class TasksTab extends StatefulWidget {
  final String userId;

  const TasksTab({Key? key, required this.userId}) : super(key: key);

  @override
  _TasksTabState createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String sortCriteria = 'date'; // Default sort criteria

  void onSortSelected(String criteria) {
    setState(() {
      sortCriteria = criteria; // Update the sort criteria and refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      appBar: TasksAppBar(
        onSortSelected: onSortSelected, // Pass the function to AppBar
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: TaskListWidget(
              userId: widget.userId,
              sortCriteria: sortCriteria, // Use the current sort criteria
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const TasksAddBottomSheet(),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    if (userState is UserAuthenticated) {
      return TasksTab(userId: userState.userId); // Pass the user ID to TasksTab
    } else {
      return const Center(child: Text("Please reload the page 🤷‍♂️"));
    }
  }
}
