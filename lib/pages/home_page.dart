import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_list.dart';
import 'package:to_done/modules/tasks/tasks_drawer.dart';
import 'package:to_done/modules/tasks/tasks_list_appbar.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/task_add.dart';

class TasksTab extends StatelessWidget {
  final String userId;

  const TasksTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: TasksAppBar(),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: TaskListWidget(userId: userId),
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
      return TasksTab(userId: userState.userId);
    } else {
      return const Center(child: Text("Please reload page 🤷‍♂️")); // пофиксить
    }
  }
}
