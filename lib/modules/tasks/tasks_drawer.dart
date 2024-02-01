import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/lists_bloc.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserAuthenticated) {
        userId = userState.userId;
        context.read<ListsBloc>().add(FetchListsEvent(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsBloc =
        BlocProvider.of<ListsBloc>(context); // Создайте экземпляр ListsBloc

    return Drawer(
      child: Container(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Выравнивание по центру
                children: [
                  Text(
                    '2 D O N E',
                    style: TextStyle(fontSize: 35),
                  ),
                  SizedBox(height: 8), // Пространство между текстом и кнопками
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Выравнивание кнопок по центру
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_list');
                        },
                      ),
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
            BlocBuilder<ListsBloc, ListsState>(
              builder: (context, state) {
                if (state is ListsFetchedState) {
                  final lists = state.lists;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      for (var list in lists)
                        ListTile(
                          title: Text(list['title']),
                          leading: Icon(Icons.list_rounded),
                          // Обработчик нажатия для списка (можете добавить нужное действие)
                          // Попытка открыть лист 'listId'
                          onTap: () {
                            // Получаем значение 'listId' из объекта 'list'
                            String listId = list['listId'];

                            // Выводим 'listId' в консоль для проверки
                            print('Попытка открыть лист: $listId');

                            // Вызываем метод 'read' для доступа к экземпляру 'TasksBloc' и добавляем событие 'UpdateTaskFilterEvent' с переданным 'listId'
                            context
                                .read<TasksBloc>()
                                .add(UpdateTaskFilterEvent(listId));
                          },
                        ),
                    ],
                  );
                } else {
                  // Обработка других состояний или отображение заглушки, если нужно
                  return SizedBox.shrink();
                }
              },
            ),
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
