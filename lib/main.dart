import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_done/modules/core/firebase_options.dart';
import 'package:to_done/modules/core/to_done_app.dart';
import 'package:to_done/modules/core/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = LoggerBlocObserver(); //DEBUG MODE ONLY
  runApp(const ToDoneApp());
}
