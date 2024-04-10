import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/core/router.dart';
import 'package:to_done/modules/core/theme/theme_provider.dart';
import 'package:to_done/modules/auth/user_bloc.dart';
import 'package:to_done/modules/tasks/tasks_bloc.dart';
import 'package:to_done/modules/tasks/list/lists_bloc.dart';

class ToDoneApp extends StatelessWidget {
  const ToDoneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeProvider()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => ListsBloc()),
        BlocProvider(create: (context) => TasksBloc()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: context.watch<ThemeProvider>().getTheme(),
            routes: routes,
          );
        },
      ),
    );
  }
}
