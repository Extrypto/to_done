import 'package:flutter/material.dart';

class TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TasksAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("2Done"),
      backgroundColor: Theme.of(context).colorScheme.background,
      actions: [
        PopupMenuButton<String>(
          onSelected: (String result) {
            // Обработка выбора в меню
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: "hideDetails",
              child: ListTile(
                leading: Icon(Icons.visibility_off),
                title: Text("Hide details"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "view",
              child: ListTile(
                leading: Icon(Icons.remove_red_eye),
                title: Text("View"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "sort",
              child: ListTile(
                leading: Icon(Icons.sort),
                title: Text("Sort"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "share",
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text("Share"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "shortcut",
              child: ListTile(
                leading: Icon(Icons.switch_access_shortcut_add_outlined),
                title: Text("Add shortcut to homescreen"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "showCompleted",
              child: ListTile(
                leading: Icon(Icons.check_circle_outline_outlined),
                title: Text("Show completed tasks"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Обязательно для AppBar
}
