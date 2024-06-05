import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSortSelected;

  const TasksAppBar({Key? key, required this.onSortSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("2DONE"),
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
            // const PopupMenuItem<String>(
            //   value: "filter",
            //   child: ListTile(
            //     leading: Icon(Icons.low_priority_rounded),
            //     title: Text("Filter"),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Sort by creation date'),
                onTap: () {
                  Navigator.pop(context);
                  onSortSelected('date');
                },
              ),
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Sort by name'),
                onTap: () {
                  Navigator.pop(context);
                  onSortSelected('name');
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.flag),
                title: Text('Sort by priority'),
                onTap: () {
                  Navigator.pop(context);
                  onSortSelected('priority');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
