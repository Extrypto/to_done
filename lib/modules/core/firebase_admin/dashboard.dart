// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDashboard extends StatelessWidget {
  final String userId =
      'eP7V9WbW6iYiAzHJMOiTbDrpzAt1'; // Замените на актуальный userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: printTaskDocumentNames,
              child: const Text('Получить названия документов'),
            ),
            ElevatedButton(
              onPressed: moveDocuments,
              child: const Text('Переместить документы'),
            ),
            // Другие кнопки...
          ],
        ),
      ),
    );
  }

  Future<void> printTaskDocumentNames() async {
    // Создание ссылки на Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Получение документов из коллекции tasks
    var tasksSnapshot = await firestore.collection('tasks').get();
    for (var doc in tasksSnapshot.docs) {
      print('Название документа: ${doc.id}');
    }
  }

  Future<void> moveDocuments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var tasksSnapshot = await firestore.collection('tasks').get();
      for (var doc in tasksSnapshot.docs) {
        await firestore
            .collection('users/$userId/tasks')
            .doc(doc.id)
            .set(doc.data());

        print('TaskId ${doc.id} был перемещен');

        // Задержка 3 секунды перед обработкой следующего документа
        await Future.delayed(const Duration(seconds: 3));

        // Если нужно удалить старый документ, раскомментируйте следующую строку
        // await doc.reference.delete();
      }

      print('Все документы перемещены');
    } catch (e) {
      print('Произошла ошибка при перемещении документов: $e');
      // Можно также использовать ScaffoldMessenger для отображения ошибок в виджете SnackBar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }
}
