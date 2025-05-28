import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final TaskService _taskService = TaskService();
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  TaskCategory? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allTasks = await _taskService.getTasks();
      _tasks = _applyFiltersLocally(allTasks);
    } catch (error) {
      debugPrint('Error loading tasks: $error');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Task> _applyFiltersLocally(List<Task> tasks) {
    return tasks.where((task) {
      final matchCategory = _selectedCategory == null || task.category == _selectedCategory;
      final matchPriority = _selectedPriority == null || task.priority == _selectedPriority;
      return matchCategory && matchPriority;
    }).toList();
  }

  void filterByCategory(TaskCategory? category) {
    _selectedCategory = category;
    _loadTasks();
  }

  void filterByPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    _loadTasks();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedPriority = null;
    _loadTasks();
  }

  Future<void> addTask(Task task) async {
    try {
      await _taskService.addTask(task);
      await _loadTasks();
    } catch (error) {
      debugPrint('Error adding task: $error');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
      await _loadTasks();
    } catch (error) {
      debugPrint('Error updating task: $error');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      await _loadTasks();
    } catch (error) {
      debugPrint('Error deleting task: $error');
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final task = _tasks[index];
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        await _taskService.updateTask(updatedTask);
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error toggling task status: $error');
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    try {
      return await _taskService.searchTasks(query);
    } catch (error) {
      debugPrint('Error searching tasks: $error');
      return [];
    }
  }

  Future<void> importTasksFromCsv(List<Map<String, dynamic>> maps) async {
    try {
      print('Importando tarefas: $maps');
      await _taskService.addTasksFromMapList(maps);
      await _loadTasks();
    } catch (error) {
      debugPrint('Error importing tasks: $error');
    }
  }

  Future<List<Map<String, dynamic>>> exportTasksToCsv() async {
    try {
      return await _taskService.getAllTasksAsMapList();
    } catch (error) {
      debugPrint('Error exporting tasks: $error');
      return [];
    }
  }
}
