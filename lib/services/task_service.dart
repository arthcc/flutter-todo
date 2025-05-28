import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskService {
  static const String _tasksKey = 'tasks';
  final uuid = Uuid();

  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  // Get all tasks
  Future<List<Task>> getTasks() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];
      return tasksJson.map((taskJson) => Task.fromMap(jsonDecode(taskJson))).toList();
    } else {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('tasks');
      return result.map((row) => Task.fromMap(row)).toList();
    }
  }

  // Save all tasks (Web only)
  Future<void> saveTasks(List<Task> tasks) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => jsonEncode(task.toMap())).toList();
      await prefs.setStringList(_tasksKey, tasksJson);
    }
  }

  // Add task
  Future<void> addTask(Task task) async {
    if (kIsWeb) {
      final tasks = await getTasks();
      tasks.add(task);
      await saveTasks(tasks);
    } else {
      final db = await DatabaseHelper.instance.database;
      await db.insert('tasks', task.toMap());
    }
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    if (kIsWeb) {
      final tasks = await getTasks();
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        await saveTasks(tasks);
      }
    } else {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'tasks',
        updatedTask.toMap(),
        where: 'id = ?',
        whereArgs: [updatedTask.id],
      );
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    if (kIsWeb) {
      final tasks = await getTasks();
      tasks.removeWhere((task) => task.id == id);
      await saveTasks(tasks);
    } else {
      final db = await DatabaseHelper.instance.database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get tasks filtered by category
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.category == category).toList();
  }

  // Get tasks filtered by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getTasks();
    final lowerQuery = query.toLowerCase();
    return tasks.where((task) =>
      task.title.toLowerCase().contains(lowerQuery) ||
      task.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Import tasks from CSV
  Future<void> addTasksFromMapList(List<Map<String, dynamic>> maps) async {
    final tasks = maps.map((map) {
      final priority = TaskPriority.values.firstWhere(
        (p) => p.name.toLowerCase() == map['priority'].toString().toLowerCase(),
        orElse: () => TaskPriority.medium,
      );
      final category = TaskCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == map['category'].toString().toLowerCase(),
        orElse: () => TaskCategory.other,
      );

      return Task(
        id: uuid.v4(),
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        isCompleted: map['completed'] ?? false,
        priority: priority,
        category: category,
      );
    }).toList();

    if (kIsWeb) {
      final existingTasks = await getTasks();
      await saveTasks([...existingTasks, ...tasks]);
    } else {
      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();
      for (var task in tasks) {
        batch.insert('tasks', task.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  // Export tasks for CSV
  Future<List<Map<String, dynamic>>> getAllTasksAsMapList() async {
    final tasks = await getTasks();
    return tasks.map((t) => {
      "title": t.title,
      "description": t.description,
      "completed": t.isCompleted,
      "priority": t.priority.name,
      "category": t.category.name,
    }).toList();
  }
}
