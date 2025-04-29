import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskCategory { 
  personal, 
  work, 
  shopping, 
  health, 
  education, 
  other 
}

extension TaskCategoryExtension on TaskCategory {
  String get name {
    switch (this) {
      case TaskCategory.personal: return 'Pessoal';
      case TaskCategory.work: return 'Trabalho';
      case TaskCategory.shopping: return 'Compras';
      case TaskCategory.health: return 'Saúde';
      case TaskCategory.education: return 'Educação';
      case TaskCategory.other: return 'Outro';
    }
  }
  
  IconData get icon {
    switch (this) {
      case TaskCategory.personal: return Icons.person;
      case TaskCategory.work: return Icons.work;
      case TaskCategory.shopping: return Icons.shopping_cart;
      case TaskCategory.health: return Icons.favorite;
      case TaskCategory.education: return Icons.school;
      case TaskCategory.other: return Icons.category;
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low: return 'Baixa';
      case TaskPriority.medium: return 'Média';
      case TaskPriority.high: return 'Alta';
    }
  }
  
  Color get color {
    switch (this) {
      case TaskPriority.low: return Colors.green;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.high: return Colors.red;
    }
  }
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  TaskPriority priority;
  TaskCategory category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
  
  // Convert to Map for saving to shared preferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority.index,
      'category': category.index,
    };
  }
  
  // Create from Map when reading from shared preferences
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate']) : null,
      priority: TaskPriority.values[map['priority']],
      category: TaskCategory.values[map['category']],
    );
  }
} 