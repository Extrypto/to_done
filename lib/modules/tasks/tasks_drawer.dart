import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart'; // Убедитесь, что путь до TasksBloc правильный

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Выравнивание элементов по ширине
                children: [
                  Text(
                    '2 D O N E',
                    style: TextStyle(fontSize: 35),
                  ),
                  Row(
                    // Добавление кнопок справа от текста
                    children: [
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/dashboard');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Today"),
              leading: const Icon(Icons.wb_sunny_outlined),
              onTap: () => _updateTaskFilter(context, "MyDay"),
            ),
            ListTile(
              title: const Text("Important"),
              leading: const Icon(Icons.star_border_outlined),
              onTap: () => _updateTaskFilter(context, "Important"),
            ),
            ListTile(
              title: const Text("Inbox"),
              leading: const Icon(Icons.not_listed_location_outlined),
              onTap: () => _updateTaskFilter(context, "Inbox"),
            ),
            ListTile(
              title: const Text("All Tasks"),
              leading: const Icon(Icons.all_inclusive_rounded),
              onTap: () => _updateTaskFilter(context, "All"),
            ),
            ListTile(
              title: const Text("Completed"),
              leading: const Icon(Icons.check_circle_outline_rounded),
              onTap: () => _updateTaskFilter(context, "Completed"),
            ),
            ListTile(
              title: const Text("Archive"),
              leading: const Icon(Icons.archive_outlined),
              onTap: () => _updateTaskFilter(context, "Archive"),
            ),
            ListTile(
              title: const Text("Trash"),
              leading: const Icon(Icons.delete_outline_rounded),
              onTap: () => _updateTaskFilter(context, "Trash"),
            ),
            // Повторите для остальных пунктов меню
          ],
        ),
      ),
    );
  }

  void _updateTaskFilter(BuildContext context, String newFilter) {
    // Отправка события обновления фильтра в TasksBloc
    context.read<TasksBloc>().add(UpdateTaskFilterEvent(newFilter));

    // Закрытие меню после выбора фильтра
    Navigator.pop(context);
  }
}
