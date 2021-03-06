import 'package:flutter/material.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:todo_hive/controllers/sort_task.dart';

import '../models/task_model.dart';

ValueNotifier<List<TaskModel>> pendingTaskListNotifier = ValueNotifier([]);
ValueNotifier<List<TaskModel>> starredTaskListNotifier = ValueNotifier([]);
ValueNotifier<List<TaskModel>> completedTaskListNotifier = ValueNotifier([]);

Future addTask(TaskModel task) async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  final id = await taskDB.add(task);
  task.id = id;
  taskDB.put(task.id, task);
  pendingTaskListNotifier.value.add(task);
  sortTask(pendingTaskListNotifier.value);
  refreshUI();
}

refreshUI() {
  pendingTaskListNotifier.notifyListeners();
  starredTaskListNotifier.notifyListeners();
  completedTaskListNotifier.notifyListeners();
}

Future<void> deleteTask(int id) async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  await taskDB.delete(id);

  await Hive.deleteBoxFromDisk('$id');
  getAllTask();
}

Future<void> updateTask(TaskModel task) async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  await taskDB.put(task.id, task);

  getAllTask();
}

Future<void> getAllTask() async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  pendingTaskListNotifier.value.clear();
  starredTaskListNotifier.value.clear();
  completedTaskListNotifier.value.clear();

  for (var _task in taskDB.values) {
    if (_task.isCompleted) {
      completedTaskListNotifier.value.add(_task);
    } else if (_task.isStarred) {
      starredTaskListNotifier.value.add(_task);
      pendingTaskListNotifier.value.add(_task);
    } else {
      pendingTaskListNotifier.value.add(_task);
    }
  }
  sortTask(pendingTaskListNotifier.value);
  sortTask(starredTaskListNotifier.value);
  sortTask(completedTaskListNotifier.value);
  refreshUI();
}
