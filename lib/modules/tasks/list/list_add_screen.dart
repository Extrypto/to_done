import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/list/lists_bloc.dart';

class AddListScreen extends StatefulWidget {
  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final TextEditingController titleController = TextEditingController();
  Color _selectedColor = Colors.transparent; //Default list color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create List'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.check_outlined, size: 30),
            onPressed: () {
              final title = titleController.text;
              if (title.isNotEmpty) {
                final userState = context.read<UserBloc>().state;
                if (userState is UserAuthenticated) {
                  final userId = userState.userId;
                  // Убедимся, что передаём правильные параметры
                  BlocProvider.of<ListsBloc>(context)
                      .add(CreateListEvent(userId, title));
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    prefixIcon: Icon(Icons.list_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear_rounded),
                      onPressed: () => titleController.clear(),
                    ),
                    hintText: 'Name',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _folderAndColorCard(context),
          ],
        ),
      ),
    );
  }

  Widget _folderAndColorCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Folder"),
                  Row(
                    children: [
                      Text("None"),
                      Icon(Icons.keyboard_arrow_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
            onTap: () => _showColorPicker(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Color"),
                  Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedColor,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: _selectedColor),
              Icon(Icons.keyboard_arrow_right_rounded),
            ],
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    final List<Map<String, dynamic>> predefinedColors = [
      {'color': Colors.transparent, 'name': 'None'},
      {'color': Colors.red, 'name': 'Red'},
      {'color': Colors.blue, 'name': 'Blue'},
      {'color': Colors.green, 'name': 'Green'},
      {'color': Colors.yellow, 'name': 'Yellow'},
      {'color': Colors.orange, 'name': 'Orange'},
      {'color': Colors.purple, 'name': 'Purple'},
      {'color': Colors.teal, 'name': 'Teal'},
      {'color': Colors.pink, 'name': 'Pink'},
      {'color': Colors.indigo, 'name': 'Indigo'},
      {'color': Colors.cyan, 'name': 'Cyan'},
      {'color': Colors.amber, 'name': 'Amber'},
      {'color': Colors.brown, 'name': 'Brown'},
      {'color': Colors.deepOrange, 'name': 'Deep Orange'},
      {'color': Colors.deepPurple, 'name': 'Deep Purple'},
      {'color': Colors.lime, 'name': 'Lime'},
      {'color': Colors.lightBlue, 'name': 'Light Blue'},
      {'color': Colors.lightGreen, 'name': 'Light Green'},
      {'color': Colors.grey, 'name': 'Grey'},
      {'color': Colors.blueGrey, 'name': 'Blue Grey'},
      {'color': Colors.black, 'name': 'Black'},
      {'color': Colors.redAccent, 'name': 'Red Accent'},
      {'color': Colors.blueAccent, 'name': 'Blue Accent'},
      {'color': Colors.greenAccent, 'name': 'Green Accent'},
      {'color': Colors.yellowAccent, 'name': 'Yellow Accent'},
      {'color': Colors.orangeAccent, 'name': 'Orange Accent'},
      {'color': Colors.purpleAccent, 'name': 'Purple Accent'},
      {'color': Colors.tealAccent, 'name': 'Teal Accent'},
      {'color': Colors.pinkAccent, 'name': 'Pink Accent'},
      {'color': Colors.indigoAccent, 'name': 'Indigo Accent'},
      {'color': Colors.cyanAccent, 'name': 'Cyan Accent'},
      {'color': Colors.amberAccent, 'name': 'Amber Accent'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: predefinedColors.length,
          itemBuilder: (BuildContext context, int index) {
            final colorData = predefinedColors[index];
            final Color color = colorData['color'];
            final String name = colorData['name'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  Navigator.pop(context);
                });
              },
              child: ListTile(
                leading: Icon(
                  index == 0 ? Icons.format_color_reset : Icons.circle,
                  color: index == 0 ? Colors.grey : color,
                ),
                title: Text(name),
              ),
            );
          },
        );
      },
    );
  }
}
