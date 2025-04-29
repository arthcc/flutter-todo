import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        taskProvider.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa removida com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.priority.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.pushNamed(
              context,
              '/edit',
              arguments: task,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: task.priority.color.withOpacity(0.2),
                      radius: 16,
                      child: Icon(
                        task.category.icon,
                        size: 16,
                        color: task.priority.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTaskStatus(task.id);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.priority.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 14,
                            color: task.priority.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.priority.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: task.priority.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (task.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: _getDueDateColor(task.dueDate!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(task.dueDate!),
                            ),
                          ),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task.category.icon,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.category.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (dueDate.isBefore(now) && !task.isCompleted) {
      return Colors.red;
    } else if (dueDate.isBefore(tomorrow)) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
} 