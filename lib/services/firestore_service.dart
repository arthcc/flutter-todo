import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class FirestoreService {
  static const String _tasksCollection = 'tasks';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = Uuid();

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // Get collection reference
  CollectionReference get _tasksRef => _firestore.collection(_tasksCollection);

  // Get all tasks
  Future<List<Task>> getTasks() async {
    try {
      final querySnapshot = await _tasksRef.get();
      return querySnapshot.docs
          .map((doc) => Task.fromFirestoreMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar tasks: $e');
      return [];
    }
  }

  // Get tasks stream for real-time updates
  Stream<List<Task>> getTasksStream() {
    return _tasksRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestoreMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add task
  Future<void> addTask(Task task) async {
    try {
      print('🔥 Tentando adicionar task: ${task.title}');
      print('🔥 Task data: ${task.toFirestoreMap()}');
      await _tasksRef.doc(task.id).set(task.toFirestoreMap());
      print('✅ Task adicionada com sucesso no Firestore!');
    } catch (e) {
      print('❌ Erro ao adicionar task: $e');
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    try {
      await _tasksRef.doc(updatedTask.id).update(updatedTask.toFirestoreMap());
    } catch (e) {
      print('Erro ao atualizar task: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      await _tasksRef.doc(id).delete();
    } catch (e) {
      print('Erro ao deletar task: $e');
      rethrow;
    }
  }

  // Get tasks filtered by category
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    try {
      final querySnapshot = await _tasksRef
          .where('category', isEqualTo: category.index)
          .get();
      return querySnapshot.docs
          .map((doc) => Task.fromFirestoreMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar tasks por categoria: $e');
      return [];
    }
  }

  // Get tasks filtered by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    try {
      final querySnapshot = await _tasksRef
          .where('priority', isEqualTo: priority.index)
          .get();
      return querySnapshot.docs
          .map((doc) => Task.fromFirestoreMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar tasks por prioridade: $e');
      return [];
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final querySnapshot = await _tasksRef.get();
      final allTasks = querySnapshot.docs
          .map((doc) => Task.fromFirestoreMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      final lowerQuery = query.toLowerCase();
      return allTasks.where((task) =>
          task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      print('Erro ao pesquisar tasks: $e');
      return [];
    }
  }

  // Import tasks from CSV
  Future<void> addTasksFromMapList(List<Map<String, dynamic>> maps) async {
    try {
      final batch = _firestore.batch();
      
      for (var map in maps) {
        final priority = TaskPriority.values.firstWhere(
          (p) => p.name.toLowerCase() == map['priority'].toString().toLowerCase(),
          orElse: () => TaskPriority.medium,
        );
        final category = TaskCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == map['category'].toString().toLowerCase(),
          orElse: () => TaskCategory.other,
        );

        final task = Task(
          id: uuid.v4(),
          title: map['title'] ?? '',
          description: map['description'] ?? '',
          isCompleted: map['completed'] ?? false,
          priority: priority,
          category: category,
        );

        batch.set(_tasksRef.doc(task.id), task.toFirestoreMap());
      }
      
      await batch.commit();
    } catch (e) {
      print('Erro ao importar tasks: $e');
      rethrow;
    }
  }

  // Export tasks for CSV
  Future<List<Map<String, dynamic>>> getAllTasksAsMapList() async {
    try {
      final tasks = await getTasks();
      return tasks.map((t) => {
        "title": t.title,
        "description": t.description,
        "completed": t.isCompleted,
        "priority": t.priority.name,
        "category": t.category.name,
      }).toList();
    } catch (e) {
      print('Erro ao exportar tasks: $e');
      return [];
    }
  }
} 