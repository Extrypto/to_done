import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/list/lists_bloc.dart';

IconData getIconFromString(String iconString) {
  // Извлекаем шестнадцатеричный код из строки
  final match = RegExp(r'U\+([0-9a-fA-F]+)').firstMatch(iconString);
  if (match != null && match.groupCount > 0) {
    final codePoint = int.tryParse(match.group(1)!, radix: 16);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
  }
  return Icons.list;
}

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
    final listsBloc = BlocProvider.of<ListsBloc>(context);

    return Drawer(
      child: Container(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0), // Отступы внутри контейнера
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Выравнивание по центру
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Выравнивание по центру
                    children: [
                      const Text(
                        '2 D O N E',
                        style: TextStyle(fontSize: 33),
                      ),
                      const SizedBox(
                          width: 8), // Пространство между текстом и иконками
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_list');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/search');
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
                  const SizedBox(
                      height: 8), // Пространство под строкой текста и иконок
                ],
              ),
            ),

            ListTile(
              title: const Text(
                "Today",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.wb_sunny_outlined),
              onTap: () => _updateTaskFilter(context, "MyDay"),
            ),
            // ListTile(
            //   title: const Text("Pinned (ex.Important)"),
            //   leading: const Icon(Icons.push_pin_outlined),
            //   onTap: () => _updateTaskFilter(context, "Important"),
            // ),
            ListTile(
              title: const Text(
                "Inbox",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.not_listed_location_outlined),
              onTap: () => _updateTaskFilter(context, "Inbox"),
            ),
            ListTile(
              title: const Text(
                "All Tasks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons
                  .all_inclusive_rounded), //FaIcon(FontAwesomeIcons.infinity)
              onTap: () => _updateTaskFilter(context, "All"),
            ),
            ListTile(
              title: const Text(
                "Completed",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.check_circle_outline_rounded),
              onTap: () => _updateTaskFilter(context, "Completed"),
            ),
            ListTile(
              title: const Text(
                "Archive",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.archive_outlined),
              onTap: () => _updateTaskFilter(context, "Archive"),
            ),
            ListTile(
              title: const Text(
                "Trash",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                      for (var list in lists)
                        ListTile(
                          title: Text(
                            list['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: Icon(getIconFromString(list['icon'])),
                          onTap: () {
                            String listId = list['listId'];
                            print('Попытка открыть лист: $listId');
                            context
                                .read<TasksBloc>()
                                .add(UpdateTaskFilterEvent(listId));
                            Navigator.pop(context); // Закрывает боковое меню
                          },
                        ),
                    ],
                  );
                } else {
                  // Обработка других состояний или отображение заглушки, если нужно
                  return const SizedBox.shrink();
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
