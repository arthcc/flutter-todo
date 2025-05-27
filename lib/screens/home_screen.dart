import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_flutter_app/services/csv_utils.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showCompleted = _tabController.index == 1;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final imported = await CsvUtils.importCsv();

              if (!mounted) return;

              if (imported.isNotEmpty) {

                await context.read<TaskProvider>().importTasksFromCsv(imported);

                if (!mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importação concluída')),
                );
              }
            },
            tooltip: 'Importar CSV',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final tasks = await context.read<TaskProvider>().exportTasksToCsv();

              if (!mounted) return;

              final resultMessage = await CsvUtils.exportCsv(tasks);

              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resultMessage)),
              );
            },
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
            tooltip: 'Pesquisar tarefas',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrar tarefas',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
            tooltip: 'Sobre o app',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Concluídas'),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final tasks = taskProvider.tasks;
          final filteredTasks = tasks.where((task) => task.isCompleted == _showCompleted).toList();
          
          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showCompleted ? Icons.check_circle_outline : Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showCompleted
                        ? 'Nenhuma tarefa concluída'
                        : 'Nenhuma tarefa pendente',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_showCompleted)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Tarefa'),
                      onPressed: () => Navigator.pushNamed(context, '/add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // ajuste conforme necessário
                      ),
                    ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              if (taskProvider.selectedCategory != null || taskProvider.selectedPriority != null)
                _buildActiveFiltersBar(taskProvider),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    key: ValueKey<int>(filteredTasks.length),
                    padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskItem(task: filteredTasks[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        tooltip: 'Adicionar Tarefa',
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
  
  Widget _buildActiveFiltersBar(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          const Text('Filtros:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (taskProvider.selectedCategory != null)
            Chip(
              label: Text(taskProvider.selectedCategory!.name),
              avatar: Icon(taskProvider.selectedCategory!.icon, size: 16),
              deleteIcon: const Icon(Icons.clear, size: 16),
              onDeleted: () => taskProvider.filterByCategory(null),
            ),
          const SizedBox(width: 8),
          if (taskProvider.selectedPriority != null)
            Chip(
              label: Text(taskProvider.selectedPriority!.name),
              backgroundColor: taskProvider.selectedPriority!.color.withOpacity(0.1),
              deleteIcon: const Icon(Icons.clear, size: 16),
              onDeleted: () => taskProvider.filterByPriority(null),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => taskProvider.clearFilters(),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Filtrar Tarefas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categorias',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.3,
                    children: TaskCategory.values.map((category) {
                      final isSelected = taskProvider.selectedCategory == category;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            taskProvider.filterByCategory(
                              isSelected ? null : category,
                            );
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[600],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prioridade',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = taskProvider.selectedPriority == priority;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              taskProvider.filterByPriority(
                                isSelected ? null : priority,
                              );
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority.color.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? priority.color
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: isSelected ? priority.color : Colors.grey[600],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  priority.name,
                                  style: TextStyle(
                                    color: isSelected ? priority.color : Colors.grey[600],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      taskProvider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar Filtros'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 