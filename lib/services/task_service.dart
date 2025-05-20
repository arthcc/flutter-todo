import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart'; 

class TaskService {
  static const String _tasksKey = 'tasks';
  final uuid = Uuid();
  // Singleton pattern
  static final TaskService _instance = TaskService._internal();
  
  factory TaskService() {
    return _instance;
  }
  
  TaskService._internal();
  
  // Get all tasks
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    return tasksJson
        .map((taskJson) => Task.fromMap(jsonDecode(taskJson)))
        .toList();
  }
  
  // Save all tasks
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks
        .map((task) => jsonEncode(task.toMap()))
        .toList();
    
    await prefs.setStringList(_tasksKey, tasksJson);
  }
  
  // Add a new task
  Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }
  
  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == id);
    await saveTasks(tasks);
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
  
  // Search tasks by title or description
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getTasks();
    final lowerQuery = query.toLowerCase();
    
    return tasks.where((task) => 
      task.title.toLowerCase().contains(lowerQuery) || 
      task.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

// Importar tarefas de CSV (lista de mapas)
  Future<void> addTasksFromMapList(List<Map<String, dynamic>> maps) async {
    final existingTasks = await getTasks();

    final newTasks = maps.map((map) {
      final priority = TaskPriority.values.firstWhere(
        (p) => p.name.toLowerCase() == map['priority'].toString().toLowerCase(),
        orElse: () => TaskPriority.medium,
      );

      final category = TaskCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == map['category'].toString().toLowerCase(),
        orElse: () => TaskCategory.other,
      );

      return Task(
        id: uuid.v4(), // ✅ usa UUID em vez de timestamp
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        isCompleted: map['completed']?.toString().toLowerCase() == 'true',
        priority: priority,
        category: category,
      );
    }).toList();

    final allTasks = [...existingTasks, ...newTasks];
    await saveTasks(allTasks);
  }

  // Exportar todas as tarefas como lista de Map (para salvar em CSV)
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