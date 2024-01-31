import 'package:cloud_firestore/cloud_firestore.dart';

class TaskUpdate {
  static Future<void> toggleTaskStatus(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusDone': newStatus});
    } catch (error) {
      print('Error toggling task status: $error');
    }
  }

  static Future<void> toggleTaskImportance(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusImportant': newStatus});
    } catch (error) {
      print('Error toggling task importance: $error');
    }
  }

  static Future<void> toggleTaskMyDayStatus(
      String userId, String taskId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'statusMyDay': newStatus});
    } catch (error) {
      print('Error toggling task MyDay status: $error');
    }
  }

  static Future<void> toggleArchiveStatus(
      String userId, String taskId, bool newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusArchived': newStatus});
  }

  static Future<void> toggleDeleteStatus(
      String userId, String taskId, bool newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'statusDeleted': newStatus});
  }

  static Future<void> updateTaskTitle(
      String userId, String taskId, String title) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'title': title});
  }
}
