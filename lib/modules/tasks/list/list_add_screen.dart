import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/list/lists_bloc.dart';

class AddListScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add List'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_outlined,
              size: 30,
            ),
            onPressed: () {
              final title = titleController.text;
              if (title.isNotEmpty) {
                final userState = context.read<UserBloc>().state;
                if (userState is UserAuthenticated) {
                  final userId = userState.userId;
                  BlocProvider.of<ListsBloc>(context)
                      .add(CreateListEvent(userId, title));
                  Navigator.of(context).pop(); // Закрывает текущую страницу
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                prefixIcon: IconButton(
                  icon: Icon(Icons.list_rounded),
                  onPressed: () {},
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _colorCircle(Colors.white),
                        _colorCircle(Colors.red),
                        _colorCircle(Colors.orange),
                        _colorCircle(Colors.yellow),
                        _colorCircle(Colors.green),
                        _colorCircle(Colors.blue),
                        _colorCircle(Colors.lightBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _folderAndToggleCard(),
          ],
        ),
      ),
    );
  }

  Widget _folderAndToggleCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Folder"),
                Row(
                  children: [
                    Text("None"),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Don't show in Smart List"),
                Switch(value: true, onChanged: (newValue) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return CircleAvatar(
      backgroundColor: color,
    );
  }
}
