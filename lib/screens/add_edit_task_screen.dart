import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final bool isEditing;

  const AddEditTaskScreen({super.key, this.isEditing = false});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  bool _isCompleted = false;
  String? _taskId;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.personal;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // If editing, load task data from arguments
    if (widget.isEditing) {
      final task = ModalRoute.of(context)!.settings.arguments as Task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _isCompleted = task.isCompleted;
      _taskId = task.id;
      _dueDate = task.dueDate;
      _priority = task.priority;
      _category = task.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Generate UUID for new tasks
      final id = _taskId ?? const Uuid().v4();
      
      final task = Task(
        id: id,
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: _isCompleted,
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
      );
      
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (widget.isEditing) {
        taskProvider.updateTask(task);
      } else {
        taskProvider.addTask(task);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Tarefa' : 'Adicionar Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (widget.isEditing)
                CheckboxListTile(
                  title: const Text('Tarefa concluída'),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Data de Vencimento',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12.0),
                      Text(
                        _dueDate == null
                            ? 'Selecionar data'
                            : DateFormat('dd/MM/yyyy').format(_dueDate!),
                        style: TextStyle(
                          color: _dueDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Prioridade',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _buildPriorityOption(TaskPriority.low, 'Baixa'),
                  const SizedBox(width: 8.0),
                  _buildPriorityOption(TaskPriority.medium, 'Média'),
                  const SizedBox(width: 8.0),
                  _buildPriorityOption(TaskPriority.high, 'Alta'),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<TaskCategory>(
                value: _category,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                ),
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _category = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  widget.isEditing ? 'Atualizar' : 'Salvar',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPriorityOption(TaskPriority priority, String label) {
    final isSelected = _priority == priority;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? priority.color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? priority.color : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag,
                color: isSelected ? priority.color : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? priority.color : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 