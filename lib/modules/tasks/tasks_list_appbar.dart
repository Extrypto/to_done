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
            if (result == "sort") {
              _showSortOptions(context);
            } else if (result == "filter") {
              // Действия для фильтрации
            } else if (result == "showCompleted") {
              // Действия для отображения выполненных задач
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: "sort",
              child: ListTile(
                leading: Icon(Icons.format_list_numbered_rounded),
                title: Text("Sort"),
              ),
            ),
            const PopupMenuItem<String>(
              value: "filter",
              child: ListTile(
                leading: Icon(Icons.low_priority_rounded),
                title: Text("Filter"),
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Sort by name'),
                onTap: () {
                  Navigator.pop(context);
                  // Здесь вызовите свою логику сортировки по названию
                },
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Sort by creation date'),
                onTap: () {
                  Navigator.pop(context);
                  // Здесь вызовите свою логику сортировки по дате создания
                },
              ),
              ListTile(
                leading: Icon(Icons.priority_high),
                title: Text('Sort by priority'),
                onTap: () {
                  Navigator.pop(context);
                  // Здесь вызовите свою логику сортировки по приоритетности
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
