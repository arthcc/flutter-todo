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
    print('Tarefas carregadas: $_tasks'); 
    _isLoading = true;
    notifyListeners();
    
    try {
      _tasks = await _taskService.getTasks();
      _applyFilters();
    } catch (error) {
      debugPrint('Error loading tasks: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _applyFilters() {
    var filteredTasks = _taskService.getTasks();
    
    if (_selectedCategory != null) {
      filteredTasks = _taskService.getTasksByCategory(_selectedCategory!);
    }
    
    if (_selectedPriority != null) {
      filteredTasks = _taskService.getTasksByPriority(_selectedPriority!);
    }
    
    filteredTasks.then((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }
  
  void filterByCategory(TaskCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }
  
  void filterByPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    _applyFilters();
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
        await _loadTasks();
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