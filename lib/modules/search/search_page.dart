import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/task_view.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle actions here
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'clear_search_history',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Clear search history'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'hide_completed_items',
                  child: ListTile(
                    leading: Icon(Icons.visibility_off),
                    title: Text('Hide completed items'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialContent()
          : _buildSearchResults(_searchQuery),
    );
  }

  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'What would you like to find?\nYou can search within tasks, steps, and notes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String query) {
    final userState = context.read<UserBloc>().state;
    if (userState is UserAuthenticated) {
      final userId = userState.userId;

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks found.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isCompleted = task['statusDone'] ?? false;
              final priority = task['priority'] ?? 0;

              Color circleColor;
              switch (priority) {
                case 1:
                  circleColor = Colors.blue;
                  break;
                case 2:
                  circleColor = Colors.orange;
                  break;
                case 3:
                  circleColor = Colors.red;
                  break;
                default:
                  circleColor = Colors.grey;
              }

              return ListTile(
                leading: IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_outlined
                        : Icons.circle_outlined,
                    color: circleColor,
                  ),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('tasks')
                        .doc(task.id)
                        .update({'statusDone': !isCompleted});
                  },
                ),
                title: Text(
                  task['title'],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskViewPage(
                        taskId: task.id,
                        userId: userId,
                        currentFilter: 'All',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } else {
      return Center(child: Text('User not authenticated.'));
    }
  }
}
